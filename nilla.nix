# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

let
  pins = import ./npins;

  nilla = import pins.nilla;
in
nilla.create (
  { config, lib }:
  {
    includes = [
      ./homes
      ./inputs.nix
      ./lib
      ./modules
      ./packages
      ./systems
      "${pins.nilla-nixos}/modules/nixos.nix" # We can't use config.inputs here without infinitely-recursing
    ];

    config = {
      packages.allNixOSSystems = {
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
                name: value: ''ln -s "${value.result.config.system.build.toplevel}" "$out/${name}"''
              ) config.systems.nixos
            ));
          };
      };

      packages.allHomes = {
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
                ''ln -s "${value.result.${stdenv.hostPlatform.system}.activationPackage}" "$out/${name}"''
              ) (config.lib.attrs.filter (_: value: value.result ? ${stdenv.hostPlatform.system}) config.homes)
            ));
          };
      };

      packages.helix = {
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

      # With a package set defined, we can create a shell.
      shells.default = {
        # Declare what systems the shell can be used on.
        systems = [ "x86_64-linux" ];

        # Define our shell environment.
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
              config.inputs.nilla-cli.result.packages.nilla-cli.result.${stdenv.hostPlatform.system}
              config.inputs.nilla-home.result.packages.nilla-home.result.${stdenv.hostPlatform.system}
              config.inputs.nilla-nixos.result.packages.nilla-nixos.result.${stdenv.hostPlatform.system}
              config.inputs.nixos-unstable.result.${stdenv.hostPlatform.system}.quickshell
              config.inputs.nixpkgs.result.${stdenv.hostPlatform.system}.deadnix
              config.packages.nilla-fmt.result.${stdenv.hostPlatform.system}
              config.packages.treefmt.result.${stdenv.hostPlatform.system}
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
)
