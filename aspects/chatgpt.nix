{den, ...}: {
  den.aspects.chatgpt.nixos = {
    pkgs,
    username,
    ...
  }: let
    relocateElfInterpreter = pkgs.writeText "relocate-elf-interpreter.cjs" (builtins.readFile ../files/chatgpt/relocate-elf-interpreter.cjs);

    chatgpt = pkgs.stdenv.mkDerivation {
      pname = "chatgpt";
      version = "26.928.21956";

      src = pkgs.fetchurl {
        url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
        hash = "sha256-msjQcRtGATaNSd7dv1Co/lI1jLYbbZ96XBi0HtRQCtg=";
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
