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
    };
  };
}
