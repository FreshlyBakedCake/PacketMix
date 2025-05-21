# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  # Headscale service
  services.headscale = {
    enable = true;

    address = "127.0.0.1";
    port = 1024;

    settings.server_url = "https://vpn.clicks.codes";

    settings.noise.private_key_path = "/secrets/headscale_noise_private_key";

    settings.dns = {
      nameservers.global = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
      base_domain = "clicks.domains";
    };

    settings.oidc = {
      only_start_if_oidc_is_available = true;
      strip_email_domain = true;

      issuer = "https://login.clicks.codes/realms/master";

      client_id = "headscale";
      client_secret_path = "/secrets/headscale_oidc_client_secret";

      allowed_groups = [ "/clicks" ];
    };
  };

  # Nginx
  services.nginx.virtualHosts."vpn.clicks.codes" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:1024";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };

  # Impermanence
  clicks.storage.impermanence.persist.directories = [ "/var/lib.headscale" ];
}
