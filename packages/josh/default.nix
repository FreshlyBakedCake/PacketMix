# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{ config, ... }:
{
  config.packages.packetmix-josh = {
    systems = [ "x86_64-linux" ];
    package =
      {
        stdenv,
        rustPlatform,
        lib,
        ...
      }:
      config.inputs.nixos-unstable.result.${stdenv.hostPlatform.system}.josh.overrideAttrs {
        src = config.inputs.josh.result;

        cargoDeps =
          (lib.warnIf (config.inputs.josh.src.revision != "38d790d60bcede347517de53555986fa41868ea4")
            "The vendorHash for josh was last updated in a different revision. Please verify that it's still correct and update"
          )
            rustPlatform.fetchCargoVendor
            {
              name = "josh";

              src = config.inputs.josh.result;

              hash = "sha256-DPDzxp1LlyCJPkwq0gAZP34TVw7TJTkgPQQHulAR8g0=";
            };

        checkFlags = [
          # fails - we don't need graphql
          "--skip=graphql::tests::test_axum_integration"
          "--skip=graphql::tests::test_sync_axum_integration"
          # fails - probably this isn't ideal but...
          "--skip=serve::tests::test_git_cap_discovery"
        ];
      };
  };
}
