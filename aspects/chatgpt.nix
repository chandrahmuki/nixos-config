{den, ...}: {
  den.aspects.chatgpt.nixos = {
    pkgs,
    username,
    ...
  }: let
    relocateElfInterpreter = pkgs.writeText "relocate-elf-interpreter.cjs" ''
      const fs = require("node:fs");

      const [elfPath, interpreterPath] = process.argv.slice(2);
      const elf = fs.readFileSync(elfPath);
      const headerSize = 64;
      const programHeaderSize = 56;
      const sectionHeaderSize = 64;
      const scanSize = 2048;
      const ptLoad = 1;
      const ptInterp = 3;
      const expected = Buffer.from(`''${interpreterPath}\0`);

      if (elf.readUInt32BE(0) !== 0x7f454c46 || elf[4] !== 2 || elf[5] !== 1) {
        throw new Error("expected a 64-bit little-endian ELF file");
      }

      const programOffset = Number(elf.readBigUInt64LE(32));
      const programCount = elf.readUInt16LE(56);
      const sectionOffset = Number(elf.readBigUInt64LE(40));
      const sectionCount = elf.readUInt16LE(60);
      const programEnd = programOffset + programCount * programHeaderSize;
      const programs = Array.from({ length: programCount }, (_, index) => {
        const header = programOffset + index * programHeaderSize;
        return {
          header,
          type: elf.readUInt32LE(header),
          offset: Number(elf.readBigUInt64LE(header + 8)),
          vaddr: elf.readBigUInt64LE(header + 16),
          paddr: elf.readBigUInt64LE(header + 24),
          fileSize: Number(elf.readBigUInt64LE(header + 32)),
        };
      });
      const interp = programs.filter(program => program.type === ptInterp);

      if (interp.length !== 1 || programEnd + expected.length > scanSize) {
        throw new Error("unsupported ELF program-header layout");
      }

      const interpreter = interp[0];
      if (elf.subarray(interpreter.offset, interpreter.offset + interpreter.fileSize).toString() !== expected.toString()) {
        throw new Error("PT_INTERP does not contain the expected dynamic linker");
      }

      const alignment = 8;
      const targetOffset = Math.ceil(programEnd / alignment) * alignment;
      const slot = elf.subarray(targetOffset, targetOffset + expected.length);
      if (!slot.every(byte => byte === 0 || byte === 0x58 || byte === 0x5a)) {
        throw new Error("no safe PT_INTERP padding inside the detect-libc scan range");
      }

      const load = programs.find(program =>
        program.type === ptLoad &&
        targetOffset >= program.offset &&
        targetOffset + expected.length <= program.offset + program.fileSize,
      );
      if (!load) {
        throw new Error("PT_INTERP padding is not inside a PT_LOAD segment");
      }

      const targetAddress = load.vaddr + BigInt(targetOffset - load.offset);
      const targetPhysicalAddress = load.paddr + BigInt(targetOffset - load.offset);
      expected.copy(elf, targetOffset);
      elf.writeBigUInt64LE(BigInt(targetOffset), interpreter.header + 8);
      elf.writeBigUInt64LE(targetAddress, interpreter.header + 16);
      elf.writeBigUInt64LE(targetPhysicalAddress, interpreter.header + 24);
      elf.writeBigUInt64LE(BigInt(expected.length), interpreter.header + 32);
      elf.writeBigUInt64LE(BigInt(expected.length), interpreter.header + 40);

      const interpSections = Array.from({ length: sectionCount }, (_, index) => {
        const header = sectionOffset + index * sectionHeaderSize;
        return {
          header,
          offset: Number(elf.readBigUInt64LE(header + 24)),
          size: Number(elf.readBigUInt64LE(header + 32)),
        };
      }).filter(section => section.offset === interpreter.offset && section.size === interpreter.fileSize);
      if (interpSections.length !== 1) {
        throw new Error("could not locate the .interp section");
      }
      const section = interpSections[0];
      elf.writeBigUInt64LE(targetAddress, section.header + 16);
      elf.writeBigUInt64LE(BigInt(targetOffset), section.header + 24);
      elf.writeBigUInt64LE(BigInt(expected.length), section.header + 32);
      fs.writeFileSync(elfPath, elf);
    '';

    chatgpt = pkgs.stdenv.mkDerivation {
      pname = "chatgpt";
      version = "26.803.81509";

      src = pkgs.fetchurl {
        url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
        hash = "sha256-qb+Ro2j598Tuo4CCqfuPtGuNAFtxmm13FdLloZgsOOs=";
      };

      nativeBuildInputs = [
        pkgs.autoPatchelfHook
        pkgs.dpkg
        pkgs.makeWrapper
        pkgs.nodejs
      ];

      buildInputs = with pkgs; [
        alsa-lib
        at-spi2-atk
        at-spi2-core
        cairo
        cups
        dbus
        expat
        gdk-pixbuf
        glib
        graphite2
        gtk3
        libdrm
        libgbm
        libglvnd
        libnotify
        libusb1
        libxkbcommon
        nspr
        nss
        openssl
        pango
        qt5.qtbase.out
        qt6.qtbase.out
        stdenv.cc.cc.lib
        systemd
        wayland
        xz
        libX11
        libXcomposite
        libXdamage
        libXext
        libXfixes
        libXrandr
        libxcb
        libxcrypt-legacy
        zlib
      ];

      autoPatchelfIgnoreMissingDeps = ["libc.musl-x86_64.so.1"];

      unpackPhase = "dpkg-deb -x $src .";

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp -r usr/lib $out/
        install -Dm644 usr/share/applications/chatgpt.desktop $out/share/applications/chatgpt.desktop
        install -Dm644 usr/share/pixmaps/chatgpt.png $out/share/pixmaps/chatgpt.png
        makeWrapper $out/lib/chatgpt/ChatGPT $out/bin/chatgpt

        runHook postInstall
      '';

      preFixup = ''
        relocateElfInterpreter() {
          ${pkgs.nodejs}/bin/node ${relocateElfInterpreter} \
            $out/lib/chatgpt/ChatGPT \
            ${pkgs.stdenv.cc.bintools.dynamicLinker}
        }
        postFixupHooks+=(relocateElfInterpreter)
      '';

      meta = {
        description = "Official ChatGPT desktop application for Linux";
        homepage = "https://openai.com/codex/";
        mainProgram = "chatgpt";
        platforms = ["x86_64-linux"];
      };
    };
  in {
    home-manager.users.${username} = {
      home.packages = [chatgpt];
    };
  };

}
