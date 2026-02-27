{
  lib,
  buildGoModule,
}:

buildGoModule {
  pname = "muggy";
  version = "0.1.0";

  src = ../../scripts/muggy;

  vendorHash = "sha256-qVtO25+8u4NzXb3tYKfs4g63UAtn2iThlkTP26ntlJQ=";

  meta = with lib; {
    description = "Declarative MCP Manager TUI for NixOS";
    homepage = "https://github.com/david/muggy";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "muggy";
  };
}
