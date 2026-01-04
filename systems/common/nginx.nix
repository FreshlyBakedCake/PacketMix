# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, lib, ... }:
{
  # By default, nginx will serve a "best-effort" site even if there is no matching vhost
  # We can disable this by making a matching vhost and returning 444...
  # Notice how we don't enable nginx here: that makes this safe to deploy even on places that don't currently run nginx. We're effectively changing the default behavior
  services.nginx.virtualHosts."missinghost.invalid" = {
    default = true;

    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/".return = "444";

    extraConfig = ''
      ssl_reject_handshake on;
    '';
  };

  systemd.services."acme-order-renew-missinghost.invalid".enable = false;

  systemd.services."acme-missinghost.invalid" = {
    wants = lib.mkForce [
      "acme-setup.service"
    ];
    before = lib.mkForce [ ];
    restartTriggers = lib.mkForce [ ];
  };

  security.acme.acceptTerms = true;
  security.acme.certs = lib.mkIf config.services.nginx.enable {
    "missinghost.invalid" = {
      dnsProvider = "invalidns";
      listenHTTP = null;
      s3Bucket = null;
      webroot = null; # We can't use webroot as the setup service validates it...
      email = "invalid@missinghost.invalid";
    }; # Nix requires some values, even if we're actually disabling the acme-missinghost.invalid service... that's problematic if there are no defaults for the system
  };
}
