{ config, ... }:
{
  config = {
    modules.nilla = {
      home = ./modules/home.nix;
      nixos = ./modules/nixos.nix;
    };

    packages.nilla-home = {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      package =
        {
          fenix,
          makeRustPlatform,
          lib,
          installShellFiles,
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
          meta.mainProgram = "nilla-home";
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

    shells.nilla-home = {
      systems = [ "x86_64-linux" ];

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
