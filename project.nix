# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pins,
  ...
}:
{
  includes =
    (
      if builtins.pathExists ./dependencies/nilla then
        [
          ./dependencies/nilla/home/modules/home.nix
          ./dependencies/nilla/home/modules/nixos.nix
          ./dependencies/nilla/nixos/modules/nixos.nix
        ]
      else
        [
          ../nilla/home/modules/home.nix
          ../nilla/home/modules/nixos.nix
          ../nilla/nixos/modules/nixos.nix
        ]
    ) # We can't use attributes from config here without infinitely-recursing
    ++ [
      ./homes
      ./modules
      ./packages
      ./systems
    ];

  config = {
    name = "packetmix";

    packages.packetmix-allNixOSSystems = {
      systems = [ "x86_64-linux" ];

      package =
        { stdenv }:
        stdenv.mkDerivation {
          name = "all-nixos-systems";

          dontUnpack = true;

          buildPhase = ''
            mkdir -p $out
          ''
          + (builtins.concatStringsSep "\n" (
            config.lib.attrs.mapToList (
              name: value:
              builtins.trace "Evaluating the system ${name}" ''ln -s "${value.result.config.system.build.toplevel}" "$out/${name}"''
            ) config.systems.nixos
          ));
        };
    };

    packages.packetmix-allHomes = {
      systems = [ "x86_64-linux" ];

      package =
        { stdenv }:
        stdenv.mkDerivation {
          name = "all-homes";

          dontUnpack = true;

          buildPhase = ''
            mkdir -p $out
          ''
          + (builtins.concatStringsSep "\n" (
            config.lib.attrs.mapToList (
              name: value:
              builtins.trace "Evaluating the home ${name}" ''ln -s "${
                value.result.${stdenv.hostPlatform.system}.activationPackage
              }" "$out/${name}"''
            ) (config.lib.attrs.filter (_: value: value.result ? ${stdenv.hostPlatform.system}) config.homes)
          ));
        };
    };

    packages.packetmix-helix = {
      systems = [ "x86_64-linux" ];

      package =
        { helix }:
        helix.overrideAttrs (
          {
            patches ? [ ],
            ...
          }:
          {
            doCheck = false;
            patches = patches ++ [ ./patches/helix/3958-labels-for-config-menus.patch ];
          }
        );
    };

    shells.packetmix = {
      systems = [ "x86_64-linux" ];

      shell =
        {
          pkgs,
          stdenv,
          mkShell,
          kdePackages,
          reuse,
          ...
        }:
        mkShell {
          QML_IMPORT_PATH =
            lib.fp.pipe
              [
                (map (pkg: "${pkg}/lib/qt-6/qml"))
                (builtins.concatStringsSep ":")
              ]
              [
                config.inputs.nixos-unstable.result.${stdenv.hostPlatform.system}.quickshell
                kdePackages.qtdeclarative
              ];

          packages = [
            config.packages.nilla-cli.result.${stdenv.hostPlatform.system}
            config.packages.nilla-home.result.${stdenv.hostPlatform.system}
            config.packages.nilla-nixos.result.${stdenv.hostPlatform.system}
            config.inputs.nixos-unstable.result.${stdenv.hostPlatform.system}.quickshell
            config.inputs.nixpkgs.result.${stdenv.hostPlatform.system}.deadnix
            config.packages.packetmix-nilla-fmt.result.${stdenv.hostPlatform.system}
            config.packages.packetmix-treefmt.result.${stdenv.hostPlatform.system}
            (config.inputs.npins.result {
              inherit pkgs;
              inherit (stdenv.hostPlatform) system;
            })
            kdePackages.qtdeclarative
            reuse
          ];
        };
    };
  };
}
