# SPDX-FileCopyrightText: 2026 Freshly Baked Cake
#
# SPDX-License-Identifier: MIT

{
  services.jellyfin.enable = true;

  clicks.storage.impermanence.persist.directories = [
    {
      directory = "/var/lib/jellyfin";
      mode = "0770";
      group = "jellyfin";
      defaultPerms = {
        mode = "0770";
        group = "jellyfin";
      };
    }
  ];

  services.nginx.virtualHosts."jellyfin.freshly.space" = {
    enableACME = true;
    acmeRoot = null;
    addSSL = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:1040";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };
}
