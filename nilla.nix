let
  pins = import ./npins;

  nilla = import pins.nilla;
in
  nilla.create ({ config }: {
    includes = [
      ./systems
    ];

    config = {
      # Add Nixpkgs as an input (match the name you used when pinning).
      inputs = builtins.mapAttrs (_: value: { src = value; }) pins;

      # With a package set defined, we can create a shell.
      shells.default = {
        # Declare what systems the shell can be used on.
        systems = [ "x86_64-linux" ];

        # Define our shell environment.
        shell = { system, mkShell, hello, ... }:
          mkShell {
            packages = [
              config.inputs.nilla-cli.result.packages.nilla-cli.result.${system}
              config.inputs.nilla-nixos.result.packages.nilla-nixos.result.${system}
            ];
          };
      };
    };
  })
