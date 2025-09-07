# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  config.packages.octodns-config = {
    systems = [ "x86_64-linux" ];

    package =
      { pkgs, lib }:
      let
        nixos-dns = config.inputs.nixos-dns.result;
        generate = nixos-dns.utils.generate pkgs;
      in
      generate.octodnsConfig {
        config = {
          providers = {
            cloudflare = {
              class = "octodns_cloudflare.CloudflareProvider";
              token = "env/CLOUDFLARE_TOKEN";
            };
          };
        };
        zones = {
          "clicks.codes." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
          "clicks.domains." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
          "clicksminuteper.net." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
          "coded.codes." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
          "crawling.us." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
          "freshlybakedca.ke." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
          "freshly.space." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
          # "hopescaramels.com." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
          "starry.sk." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
          "starrysky.blog." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
          "starrysky.fyi." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
          "tcp.contact." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
          "thecoded.prof." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
        };
        dnsConfig = {
          nixosConfigurations = builtins.mapAttrs (name: value: value.result) config.systems.nixos;
        };
      };
  };
}
