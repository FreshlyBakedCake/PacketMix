# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@freshlybakedca.ke";
      dnsProvider = "cloudflare";
      environmentFile = "/secrets/acme/environmentFile";
      extraLegoFlags = [
        "--dns.resolvers"
        "1.1.1.1"
      ];
    };
  };

  clicks.storage.impermanence.persist.directories = [ "/var/lib/acme" ];
}
