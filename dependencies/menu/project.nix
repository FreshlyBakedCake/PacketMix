# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, lib }:
{
  config = {
    packages.default = config.packages.menu;
    packages.menu = {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      package =
        {
          fenix,
          makeRustPlatform,
          lib,
          ...
        }:
        let
          toolchain = fenix.complete.toolchain;

          manifest = (lib.importTOML ./Cargo.toml).package;

          platform = makeRustPlatform {
            cargo = toolchain;
            rustc = toolchain;
          };
        in
        platform.buildRustPackage {
          meta.mainProgram = "menu";
          pname = manifest.name;
          version = manifest.version;

          src = ./.;

          cargoLock.lockFile = ./Cargo.lock;
        };
    };

    shells.default = config.shells.menu;
    shells.menu = {
      systems = [ "x86_64-linux" ];

      shell =
        {
          bacon,
          devenv,
          fenix,
          mkShell,
          pkg-config,
          pkgs,
          reuse,
          sqlx-cli,
          stdenv,
          ...
        }:
        mkShell {
          packages = [
            bacon
            config.inputs.nilla-cli.result.packages.nilla-cli.result.${stdenv.hostPlatform.system}
            config.inputs.nixpkgs.result.${stdenv.hostPlatform.system}.deadnix
            # config.packages.nilla-fmt.result.${stdenv.hostPlatform.system}
            # config.packages.treefmt.result.${stdenv.hostPlatform.system}
            (config.inputs.npins.result {
              inherit pkgs;
              inherit (stdenv.hostPlatform) system;
            })
            devenv
            pkg-config
            reuse
            (fenix.complete.withComponents [
              "cargo"
              "clippy"
              "rust-src"
              "rustc"
              "rustfmt"
              "rust-analyzer"
            ])
            sqlx-cli
          ];
        };
    };
  };
}
