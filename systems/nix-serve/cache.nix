# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 1025 ];

  services.nix-serve = {
    enable = true;
    package = pkgs.nix-serve-ng;

    secretKeyFile = "/secrets/cache/signer.key";

    bindAddress = "0.0.0.0";
    port = 1025;
  };
}
