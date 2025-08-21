# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  services.nginx.enable = true;
  services.nginx.virtualHosts."login.clicks.codes" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    serverAliases = [ "www.login.clicks.codes" ];

    locations."/" = {
      proxyPass = "https://100.64.0.11:443";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };
  services.nginx.virtualHosts."mail.clicks.codes" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    serverAliases = [ "www.mail.clicks.codes" ];

    locations."/" = {
      proxyPass = "https://100.64.0.11:443";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };
}
