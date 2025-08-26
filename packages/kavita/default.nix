{ config, ... }:
{
  config.packages.kavita = {
    systems = [ "x86_64-linux" ];
    package = { fetchNpmDeps, ... }:
      config.inputs.nixos-unstable.result."x86_64-linux".kavita.overrideAttrs (prev: let
        version = "0.8.8";
        src = config.inputs.kavita.src // { name = "source"; };
      in {
        inherit src version;

        frontend = prev.frontend.overrideAttrs (frontend-prev: {
          inherit src version;
          npmDepsHash = "sha256-7Bpsvqg2Vhp6/WG6o85OxX4hxZ6cd3A7iVB+H3IwbpE=";
          npmDeps = fetchNpmDeps {
            inherit src;
            inherit (frontend-prev) sourceRoot;
            name = "${frontend-prev.pname}-0.8.8-npm-deps";
            hash = "sha256-7Bpsvqg2Vhp6/WG6o85OxX4hxZ6cd3A7iVB+H3IwbpE=";
          };
        });
      });
  };
}
