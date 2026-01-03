# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, lib }:
{
  config = {
    shells.default = config.shells.menu;
    shells.menu = {
      systems = [ "x86_64-linux" ];

      shell =
        {
          bacon,
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
