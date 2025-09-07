# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, ... }:
{
  imports = [ project.inputs.nixos-dns.result.nixosModules.default ];

  networking.domains = {
    enable = true;
    baseDomains = {
      "clicks.codes" = { };
      "clicksminuteper.net" = { };
      "coded.codes" = { };
      "freshly.space" = { };
      "freshlybakedca.ke" = { };
      "hopescaramels.com" = { };
      "starrysky.fyi" = { };
      "thecoded.prof" = { };
      "turquoise.fyi" = { };
    };
  };
}
