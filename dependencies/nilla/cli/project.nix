# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  pins,
  config,
  lib,
}:
{
  config = {
    name = "nilla-cli";

    packages.nilla-cli = {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      package =
        {
          fenix,
          stdenv,
          lib,
          installShellFiles,
          ...
        }:
        let
          toolchain = fenix.complete.toolchain;

          manifest = (lib.importTOML ./Cargo.toml).package;

          platform = config.inputs.nixos-unstable.result.${stdenv.hostPlatform.system}.makeRustPlatform {
            cargo = toolchain;
            rustc = toolchain;
          };
        in
        platform.buildRustPackage {
          meta.mainProgram = "nilla";
          pname = manifest.name;
          version = manifest.version;

          src = ./.;

          nativeBuildInputs = [ installShellFiles ];

          postInstall = ''
            installManPage ./target/release-tmp/build/nilla-*/out/nilla*
          '';

          cargoLock.lockFile = ./Cargo.lock;
        };
    };

    shells.nilla-cli = {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      shell =
        {
          mkShell,
          fenix,
          bacon,
          pkg-config,
          ...
        }:
        mkShell {
          packages = [
            (fenix.complete.withComponents [
              "cargo"
              "clippy"
              "rust-src"
              "rustc"
              "rustfmt"
              "rust-analyzer"
            ])
            bacon
            pkg-config
          ];
        };
    };
  };
}
