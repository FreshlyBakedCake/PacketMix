# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  security.acme = {
    defaults = {
      email = "acme@freshlybakedca.ke";
      dnsProvider = "cloudflare";
      environmentFile = "/secrets/acme/environmentFile";
    };
  };
}
