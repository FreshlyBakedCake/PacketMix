# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  networking.domains.subDomains."idm.freshly.space".cname.data = "a1.clicks.domains";

  services.kanidm = {
    package = pkgs.kanidm_1_6;
    enableServer = true;
    enableClient = true;
    serverSettings = {
      version = "2";

      bindaddress = "127.0.0.1:1029";
      domain = "idm.freshly.space";
      origin = "https://idm.freshly.space";

      tls_key = "/var/lib/kanidm/key.pem";
      tls_chain = "/var/lib/kanidm/cert.pem";

      http_client_address_info.x-forward-for = [
        "127.0.0.1"
        "127.0.0.0/8"
      ];
    };

    clientSettings.uri = "https://idm.freshly.space";
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."idm.freshly.space" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "https://127.0.0.1:1029";
      recommendedProxySettings = true;
      extraConfig = "proxy_http_version 1.1;";
    };
  };

  security.acme.certs."idm.freshly.space" = {
    postRun = ''
      cp -Lv {cert,key,chain}.pem /var/lib/kanidm/
      chown kanidm:kanidm /var/lib/kanidm/{cert,key,chain}.pem
      chmod 400 /var/lib/kanidm/{cert,key,chain}.pem
    '';
    reloadServices = [ "kanidm.service" ];
  };

  clicks.storage.impermanence.persist.directories = [
    "/var/lib/kanidm"
  ];
}
