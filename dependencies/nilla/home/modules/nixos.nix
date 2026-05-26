# SPDX-FileCopyrightText: 2025 Nilla Home contributors
#
# SPDX-License-Identifier: Apache-2.0

{ config, lib }@global:
let
  inherit (global.config) inputs;
  homes-type = import ./homes-type.nix { inherit config lib; };
in
{
  options.systems = {
    nixos = lib.options.create {
      type = lib.types.attrs.of (
        lib.types.submodule (
          { config, name, ... }@submodule:
          {
            options = {
              home-manager = lib.options.create {
                description = "The home-manager input to use.";
                type = lib.types.raw;
                default.value = if inputs ? home-manager then inputs.home-manager.result else null;
              };

              homes = lib.options.create {
                description = "Homes to activate for the system, with the same naming scheme as nilla-home's config.homes option";
                type = homes-type;
                default.value = { };
              };

              specialisedHomes = lib.options.create {
                description = "Homes to activate for specialised systems. The special value 'unspecialised' can be used to apply a home only to systems without any specialisations";
                type = lib.types.attrs.of homes-type;
                default.value = { };
              };
            };

            config.modules =
              let
                warn' = builtins.warn or builtins.trace; # builtins.warn doesn't exist on some versions of nix/lix
                warnIf =
                  condition: message: value:
                  if condition then warn' message value else value;
                homeManager = submodule.config.home-manager;
                modulesForHomes =
                  homes: condition:
                  (lib.fp.pipe [
                    (
                      value:
                      if builtins.isNull homeManager && value != [ ] then
                        builtins.throw "A home-manager instance is required to enable homes for the NixOS system \"${name}\", but none was provided and \"inputs.home-manager\" does not exist."
                      else
                        value
                    )
                    (lib.attrs.mapToList (
                      homeName: home:
                      let
                        homeNameParts = builtins.match "([a-z][-a-z0-9]*)(@([-A-Za-z0-9]+))?(:([-_A-Za-z0-9]+))?" homeName;
                        username = builtins.elemAt homeNameParts 0;
                        homeHasHomeManager = !(builtins.isNull home.home-manager);
                        homeIsValidForSystem =
                          home ? result.${config.pkgs.stdenv.hostPlatform.system or config.pkgs.system};
                      in
                      if !homeHasHomeManager then
                        builtins.throw "You've asked for the home \"${homeName}\" to be activated in the NixOS system \"${name}\", but it needs a home-manager instance, none was provided and \"inputs.home-manager\" does not exist."
                      else if !homeIsValidForSystem then
                        builtins.throw "You've asked for the home \"${homeName}\" to be activated in the NixOS system \"${name}\", but it isn't valid for \"${
                          config.pkgs.stdenv.hostPlatform.system or config.pkgs.system
                        }\" systems."
                      else
                        {
                          inherit home homeName username;
                        }
                    ))
                    (
                      values:
                      let
                        existingUsernames = map (value: value.username) (
                          builtins.filter (value: value.username != null) values
                        );
                        uniqueUsernames = lib.lists.unique existingUsernames;
                      in
                      if existingUsernames != uniqueUsernames then
                        builtins.throw "There are multiple homes for a single user in the NixOS system \"${name}\". Please make sure you've only enabled a single home per user."
                      else
                        values
                    )
                    (builtins.map (
                      {
                        home,
                        homeName,
                        username,
                      }@identity:
                      warnIf (home.home-manager != homeManager)
                        "The home \"${homeName}\" isn't using the same home-manager input as the NixOS system \"${name}\". This may work, but is not officially supported by the Nilla Home or Nilla NixOS maintainers. Please fix this before reporting any bugs you may find."
                        identity
                    ))
                    (builtins.map (
                      {
                        home,
                        homeName,
                        username,
                      }:
                      { lib, ... }:
                      {
                        _file = "virtual:nilla-nix/home/nixos/${homeName}/nixos";
                        config.home-manager.users.${username} = lib.mkIf condition (
                          { ... }:
                          {
                            _file = "virtual:nilla-nix/home/nixos/${homeName}/homeModule";
                            imports = home.modules ++ [
                              {
                                config._module.args = home.args;
                                _file = "virtual:nilla-nix/home/nixos/${homeName}/args";
                              }
                            ];
                          }
                        );
                        config.users.users.${username}.isNormalUser = lib.mkIf condition (lib.modules.mkDefault true);
                      }
                    ))
                    lib.lists.flatten
                  ] homes);
              in
              (modulesForHomes submodule.config.homes true)
              ++ (lib.attrs.mapToList (
                specialisation: homes:
                if specialisation != "unspecialised" then
                  (
                    {
                      lib,
                      ...
                    }:
                    {
                      config.specialisation.${specialisation}.configuration.imports = modulesForHomes homes true;
                    }
                  )
                else
                  (
                    {
                      lib,
                      config,
                      ...
                    }@nixos:
                    {
                      imports = modulesForHomes homes (nixos.config.specialisation != { });
                    }
                  )
              ) submodule.config.specialisedHomes)
              ++ (
                if submodule.config.homes != [ ] || submodule.config.specialisedHomes != { } then # TODO: this probably shouldn't be included if only some specialisations have any homes...
                  [
                    submodule.config.home-manager.nixosModules.default
                    {
                      config.home-manager.useGlobalPkgs = true; # Required or home modules will lose the nixpkgs config defined in nilla

                    }
                  ]
                else
                  [ ]
              );
          }
        )
      );
    };
  };
}
