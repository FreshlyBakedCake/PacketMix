let
  pins = import ./npins;

  nilla = import pins.nilla;

  settings = config: { };
in
nilla.create (
  { config }:
  {
    config.inputs =
      config.lib.attrs.generate (builtins.filter (name: name != "__functor") (builtins.attrNames pins))
        (name: {
          src = pins.${name};
          settings = (settings config).${name} or (config.lib.modules.when false { });
        });

    config.packages.hello = {
      systems = [ "x86_64-linux" ];

      package = { hello }: hello;
    };

    config.shells.default = {
      systems = [ "x86_64-linux" ];

      shell =
        { mkShell, stdenv, ... }:
        mkShell {
          packages = [
            config.packages.hello.result.${stdenv.hostPlatform.system}
          ];
        };
    };
  }
)
