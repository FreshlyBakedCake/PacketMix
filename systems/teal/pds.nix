# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  services.pds = {
    enable = true;
    settings = {
      PDS_HOSTNAME = "pds.freshly.space";
      PDS_PORT = 1033;
      PDS_SERVICE_HANDLE_DOMAINS = ".at.freshlybakedca.ke";
    };
    environmentFiles = [
      "/secrets/pds/environmentFile"
    ];
  };

  services.nginx.virtualHosts."pds.freshly.space" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    serverAliases = [ "*.at.freshlybakedca.ke" ];

    locations."/" = {
      proxyPass = "http://127.0.0.1:1033";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };

  clicks.storage.impermanence.persist.directories = [ "/var/lib/pds" ];
}
