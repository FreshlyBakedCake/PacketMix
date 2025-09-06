# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  services.cloudflare-dyndns = {
    enable = true;
    domains = [ "a1.clicks.domains" ];
    apiTokenFile = "/secrets/ddns/cloudflareAPIToken";
  };
}
