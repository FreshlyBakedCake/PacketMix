# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
#
# SPDX-License-Identifier: MIT

{
  networking.hosts = {
    "127.0.0.1" = [
      "nextcloud.local"
      "nextcloud2.local"
      "nextcloud3.local"
      "stable16.local"
      "stable17.local"
      "stable18.local"
      "stable19.local"
      "stable20.local"
      "stable21.local"
      "stable22.local"
      "stable23.local"
      "stable24.local"
      "stable25.local"
      "stable26.local"
      "stable27.local"
      "stable28.local"
      "stable29.local"
      "stable30.local"
      "stable31.local"
      "stable32.local"
      "mail.local"
      "sso.local"
      "imap.local"
      "collabora.local"
      "codedev.local"
      "onlyoffice.local"
      "proxy.local"
      "hpb.local"
      "push.local"
      "keycloak.local"
      "portal.local"
      "gs1.local"
      "gs2.local"
      "lookup.local"
      "elasticsearch.local"
      "elasticsearch-ui.local"
      "pgadmin.local"
      "phpmyadmin.local"
      "talk-signaling.local"
      "talk-recording.local"
    ];
  };

  services.nginx.virtualHosts."nextcloud.docker.dev.redhead.starrysky.fyi" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "http://127.0.0.1:8062";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };

    extraConfig = ''
      client_max_body_size 100G;
    '';
  };

  security.acme.certs."nextcloud.docker.dev.redhead.starrysky.fyi" = {
    dnsProvider = "cloudflare";
    environmentFile = "/secrets/acme/environmentFile";
    email = "skyler.grey@collabora.com";
  };
}
