# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  services.nginx.enable = true;
  services.nginx.virtualHosts."spindle.freshlybakedca.ke" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "http://midnight:1024";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };
}
