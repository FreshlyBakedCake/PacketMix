{ lib }:
let
  pins = (
    if builtins.pathExists ../../npins then
      import ../../npins # When we are accessing this in the nilla project
    else if builtins.pathExists ../../../npins then
      import ../../../npins # When we are accessing this in the toplevel project
    else
      import ../../../../npins # When we are accessing this as a dependency for another project
  );

  compat = import pins.flake-compat;
in
{
  config = {
    loaders.flake = {
      settings = {
        type = lib.types.submodule {
          options = {
            target = lib.options.create {
              description = "The relative path to the file to load.";
              type = lib.types.string;
              default.value = "flake.nix";
            };

            inputs = lib.options.create {
              description = "Inputs to replace in the loaded flake.";
              type = lib.types.attrs.of lib.types.raw;
              default.value = { };
            };
          };
        };

        default = { };
      };

      load = input:
        let
          value = compat.load {
            src = builtins.dirOf "${input.src}/${input.settings.target}";

            replacements = input.settings.inputs;
          };
        in
        value;
    };
  };
}
