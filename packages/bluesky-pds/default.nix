# SPDX-FileCopyrightText: 2003-2025 Eelco Dolstra and the Nixpkgs/NixOS contributors
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  config.packages.bluesky-atproto-pds = {
    systems = [ "x86_64-linux" ];
    package =
      {
        stdenv,
        nodejs,
        pnpm_9,
        srcOnly,
        python3,
        ...
      }:
      let
        nodeSources = srcOnly nodejs;
        pythonEnv = python3.withPackages (p: [ p.setuptools ]);
      in
      stdenv.mkDerivation (finalAttrs: {
        pname = "bluesky-atproto";
        version = config.inputs.bluesky-atproto.src.revision;

        src = config.inputs.bluesky-atproto.src;

        nativeBuildInputs = [
          nodejs
          pnpm_9.configHook
          pythonEnv
        ];

        pnpmDeps = pnpm_9.fetchDeps {
          inherit (finalAttrs) pname version src;
          fetcherVersion = 2;
          hash = "sha256-3Q3k2zTAyJHWunOLU/CuCaNljmPf9r3ONUjZ/0vno8s=";
        };

        buildPhase = ''
          runHook preBuild

          pnpm build

          # copied from nixpkgs to fix better-sqlite3 missing bindings error:
          pushd ./node_modules/.pnpm/better-sqlite3@10.0.0/node_modules/better-sqlite3
          npm run build-release --offline --nodedir="${nodeSources}"
          find build -type f -exec remove-references-to -t "${nodeSources}" {} \;
          popd

          pushd ./node_modules/.pnpm/better-sqlite3@9.6.0/node_modules/better-sqlite3
          npm run build-release --offline --nodedir="${nodeSources}"
          find build -type f -exec remove-references-to -t "${nodeSources}" {} \;
          popd

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out

          cp -r interop-test-files $out
          cp -r node_modules $out
          cp -r packages $out
          cp -r services $out

          mkdir -p $out/lib/@atproto
          ln -s $out/packages/pds $out/lib/@atproto/pds

          runHook postInstall
        '';
      });
  };
  config.packages.bluesky-pds = {
    systems = [ "x86_64-linux" ];
    package =
      {
        system,
        ...
      }:
      config.inputs.nixos-unstable.result.${system}.bluesky-pds.overrideAttrs {
        postBuild = ''
          rm -r node_modules/.pnpm/@atproto+pds@0.4.169
          mkdir -p node_modules/.pnpm/@atproto+pds@0.4.169
          ln -s ${
            config.packages.bluesky-atproto-pds.result.${system}
          }/lib node_modules/.pnpm/@atproto+pds@0.4.169/node_modules
        '';
      };
  };
}
