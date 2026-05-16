{ lib, config }:
let
  inherit (config) inputs;
in lib.types.attrs.of (lib.types.submodules.portable (
  {
    name = "home";
    description = "A home-manager home";
    module = { config }: let
      home_name = config.__module__.args.dynamic.name;
      home_name_parts = builtins.match "([a-z][-a-z0-9]*)(@([-A-Za-z0-9]+))?(:([-_A-Za-z0-9]+))?" home_name;

      argsModule = {
        config._module.args = config.args;
        _file = "virtual:nilla-nix/home/${home_name}/args";
      };

      homeForSystem = system: config.home-manager.lib.homeManagerConfiguration {
        pkgs = config.pkgs.${system};
        lib = config.pkgs.lib;
        modules = config.modules ++ [ argsModule ];
      };

      result = builtins.listToAttrs (builtins.map (system: {
        name = system;
        value = homeForSystem system;
      }) config.systems);

      username = builtins.elemAt home_name_parts 0;
      system = builtins.elemAt home_name_parts 4;

      systemProvided = system != null;

      defaultModules = [
        ({ lib, ... }: {
          home.username = lib.modules.mkDefault username;
        })
      ];
    in {
      options = {
        systems = lib.options.create {
          description = "The systems this home is valid on.";
          type = lib.types.list.of lib.types.string;
        } // (if systemProvided then {
          default.value = [ system ];
          writeable = false;
        } else {});
    
        args = lib.options.create {
          description = "Additional arguments to pass to home-manager modules.";
          type = lib.types.attrs.any;
          default.value = { };
        };

        home-manager = lib.options.create {
          description = "The home-manager input to use.";
          type = lib.types.raw;
          default.value =
            if inputs ? home-manager
            then inputs.home-manager.result
            else null;
        };

        pkgs = lib.options.create {
          description = "The Nixpkgs instance to use.";
          type = lib.types.raw;
          default.value =
            if
              inputs ? nixpkgs
            then
              inputs.nixpkgs.result
            else
              null;
        };

        modules = lib.options.create {
          description = "A list of modules to use for home-manager.";
          type = lib.types.list.of lib.types.raw;
        };

        result = lib.options.create {
          description = "The created Home Manager home for each of the systems.";
          type = lib.types.attrs.of lib.types.raw;
          writable = false;
          default.value = result;
        };
      };

      config = {
        modules = defaultModules; # Provided down here rather than as a default so they don't get overriden when a user specifies additional modules
      };
    };
  }
))
