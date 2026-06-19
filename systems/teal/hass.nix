# SPDX-FileCopyrightText: 2026 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  services.nginx.enable = true;
  services.nginx.virtualHosts."24marionave.shuert.family" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "http://192.168.2.2:8123";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };
}
