# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  networking.firewall.allowedTCPPorts = [ 1025 ];

  services.nix-serve = {
    enable = true;
    secretKeyFile = "/secrets/cache/signer.key";

    bindAddress = "0.0.0.0";
    port = 1025;
  };
}
