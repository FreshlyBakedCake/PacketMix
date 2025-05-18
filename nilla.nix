let
  pins = import ./npins;

  nilla = import pins.nilla;

  settings = {
    nixpkgs.configuration.allowUnfreePredicate = (x: (x ? meta.license) && (x.meta.license.shortName == "unfreeRedistributable")); # As we push to a public cachix, we can't use non-redistributable unfree software
    "nixos-24.11" = settings.nixpkgs;
  };
in
  nilla.create ({ config }: {
    includes = [
      ./homes
      ./lib
      ./systems
      "${pins.nilla-home}/modules/home.nix" # We can't use config.inputs here without infinitely-recursing
      "${pins.nilla-nixos}/modules/nixos.nix" # We can't use config.inputs here without infinitely-recursing
    ];

    config = {
      # Add Nixpkgs as an input (match the name you used when pinning).
      inputs = builtins.mapAttrs (name: value: {
        src = value;
        settings = settings.${name} or config.lib.constants.undefined;
      }) pins;

      packages.allNixOSSystems = {
        systems = [ "x86_64-linux" ];

        package = { stdenv }: stdenv.mkDerivation {
          name = "all-nixos-systems";

          dontUnpack = true;

          buildPhase = ''
            mkdir -p $out
          '' + (builtins.concatStringsSep "\n" (
            config.lib.attrs.mapToList (name: value: ''ln -s "${value.result.config.system.build.toplevel}" "$out/${name}"'') config.systems.nixos
          ));
        };
      };

      packages.allHomes = {
        systems = [ "x86_64-linux" ];

        package = { system, stdenv }: stdenv.mkDerivation {
          name = "all-homes";

          dontUnpack = true;

          buildPhase = ''
            mkdir -p $out
          '' + (builtins.concatStringsSep "\n" (
            config.lib.attrs.mapToList
              (name: value: ''ln -s "${value.result.${system}.activationPackage}" "$out/${name}"'')
              (config.lib.attrs.filter (_: value: value.result ? ${system}) config.homes)
          ));
        };
      };

      # With a package set defined, we can create a shell.
      shells.default = {
        # Declare what systems the shell can be used on.
        systems = [ "x86_64-linux" ];

        # Define our shell environment.
        shell = { system, npins, mkShell, reuse, ... }:
          mkShell {
            packages = [
              config.inputs.nilla-cli.result.packages.nilla-cli.result.${system}
              config.inputs.nilla-home.result.packages.nilla-home.result.${system}
              config.inputs.nilla-nixos.result.packages.nilla-nixos.result.${system}
              npins
              reuse
            ];
          };
      };
    };
  })
