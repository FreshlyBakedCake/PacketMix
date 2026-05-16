{ config, lib }@global:
let
  inherit (global.config) inputs;
  homes-type = import ./homes-type.nix { inherit config lib; };
in
{
  options.systems = {
    nixos = lib.options.create {
      type = lib.types.attrs.of (lib.types.submodule ({ config, name, ... }@submodule: {
        options = {
          home-manager = lib.options.create {
            description = "The home-manager input to use.";
            type = lib.types.raw;
            default.value =
              if inputs ? home-manager
              then inputs.home-manager.result
              else null;
          };

          homes = lib.options.create {
            description = "Homes to activate for the system, with the same naming scheme as nilla-home's config.homes option";
            type = homes-type;
            default.value = {};
          };
        };

        config.modules = let
          system = submodule.config.pkgs.system;
          warn' = builtins.warn or builtins.trace; # builtins.warn doesn't exist on some versions of nix/lix
          warnIf = condition: message: value: if condition then warn' message value else value;
          homeManager = submodule.config.home-manager;
        in (lib.fp.pipe [
          (lib.attrs.mapToList (homeName: home: let
            homeNameParts = builtins.match "([a-z][-a-z0-9]*)(@([-A-Za-z0-9]+))?(:([-_A-Za-z0-9]+))?" homeName;
            username = builtins.elemAt homeNameParts 0;
          in {
            inherit home homeName username;
          }))
          (builtins.map ({home, homeName, username}@identity:
            warnIf (home.home-manager != homeManager)
              "The home \"${homeName}\" isn't using the same home-manager input as the NixOS system \"${name}\". This may work, but is not officially supported by the Nilla Home or Nilla NixOS maintainers. Please fix this before reporting any bugs you may find."
            identity))
          (builtins.map ({home, homeName, username}: { lib, ... }: {
            _file = "virtual:nilla-nix/home/nixos/${homeName}/nixos";
            config.home-manager.useGlobalPkgs = true; # Required or home modules will lose the nixpkgs config defined in nilla
            config.home-manager.users.${username} = { ... }: {
              _file = "virtual:nilla-nix/home/nixos/${homeName}/homeModule";
              imports = home.modules ++ [ {
                config._module.args = home.args;
                _file = "virtual:nilla-nix/home/nixos/${homeName}/args";
              } ];
            };
            config.users.users.${username}.isNormalUser = lib.modules.mkDefault true;
          }))
          lib.lists.flatten
        ] submodule.config.homes) ++ (
          if submodule.config.homes != []
          then [ submodule.config.home-manager.nixosModules.default ]
          else []
        );
      }));
    };
  };

  config = {
    assertions = lib.lists.flatten (lib.attrs.mapToList
      (name: value: let
        hasNixpkgs = !(builtins.isNull value.pkgs);
        requestedHomes = value.homes != [];
        hasHomeManager = !(builtins.isNull value.home-manager);
      in [
        {
          assertion = hasNixpkgs;
          message = "A Nixpkgs instance is required for the NixOS system \"${name}\", but none was provided and \"inputs.nixpkgs\" does not exist.";
        }
        {
          assertion = !requestedHomes || hasHomeManager;
          message = "A home-manager instance is required to enable homes for the NixOS system \"${name}\", but none was provided and \"inputs.home-manager\" does not exist.";
        }
        (lib.attrs.mapToList (homeName: home: let
          homeHasHomeManager = !(builtins.isNull home.home-manager);
          homeIsValidForSystem = home ? result.${value.pkgs.system};
        in [
          {
            assertion = homeHasHomeManager;
            message = "You've asked for the home \"${homeName}\" to be activated in the NixOS system \"${name}\", but it needs a home-manager instance, none was provided and \"inputs.home-manager\" does not exist.";
          }
          {
            assertion = !homeHasHomeManager || !hasNixpkgs || homeIsValidForSystem;
            message = "You've asked for the home \"${homeName}\" to be activated in the NixOS system \"${name}\", but it isn't valid for \"${value.pkgs.system}\" systems.";
          }
        ]) value.homes)
        (let
          usernames = lib.attrs.mapToList (homeName: home: let
            homeHasHomeManager = !(builtins.isNull home.home-manager);
            homeIsValidForSystem = home ? result.${value.pkgs.system};
          in 
            if homeHasHomeManager && hasNixpkgs && homeIsValidForSystem
            then let
              homeNameParts = builtins.match "([a-z][-a-z0-9]*)(@([-A-Za-z0-9]+))?(:([-_A-Za-z0-9]+))?" homeName;
              username = builtins.elemAt homeNameParts 0;
            in username
            else null) value.homes;
          existingUsernames = builtins.filter (username: username != null) usernames;
          uniqueUsernames = lib.lists.unique existingUsernames;
        in {
          assertion = !hasNixpkgs || (existingUsernames == uniqueUsernames);
          message = "There are multiple homes for a single user in the NixOS system \"${name}\". Please make sure you've only enabled a single home per user.";
        })
      ])
      global.config.systems.nixos);
  };
}
