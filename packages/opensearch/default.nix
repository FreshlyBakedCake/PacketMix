# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{ config, ... }:
{
  config.packages.packetmix-opensearch = {
    systems = [ "x86_64-linux" ];
    package =
      {
        stdenv,
        jdk11_headless,
        ...
      }:
      (config.inputs.nixos-prev.result.${stdenv.hostPlatform.system}.opensearch.override {
        jre_headless = jdk11_headless;
      }).overrideAttrs
        {
          version = "1.3.20";
          src = config.inputs.OpenSearch.src;

          postInstall = ''
            cp bin/opensearch-cli $out/bin/opensearch-cli
            sed -i -e '/9-:-Xlog:gc/d' $out/config/jvm.options
          '';
        };
  };
}
