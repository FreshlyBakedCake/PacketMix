# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  config,
  pkgs,
  lib,
  ...
}:
let
  mail_domains = [
    "a.starrysky.fyi"
    "clicks.codes"
    "clicksminuteper.net"
    "coded.codes"
    "companies.clicks.codes"
    "companies.freshlybakedca.ke"
    "companies.starrysky.fyi"
    "companies.thecoded.prof"
    "freshly.space"
    "freshlybakedca.ke"
    "hopescaramels.com"
    "starrysky.fyi"
    "thecoded.prof"
    "turquoise.fyi"
  ];
in
{
  services.stalwart-mail = {
    enable = true;
    openFirewall = true;

    settings = {
      auth.dkim.sign = [
        {
          "if" = "is_local_domain('*', sender_domain)";
          "then" = "['rsa-' + sender_domain, 'ed25519-' + sender_domain]";
        }
        { "else" = false; }
      ];
      certificate = {
        "mail.freshly.space" = {
          cert = "${config.security.acme.certs."mail.freshly.space".directory}/fullchain.pem";
          private-key = "${config.security.acme.certs."mail.freshly.space".directory}/key.pem";
          default = true;
        };
      }
      // (lib.pipe mail_domains [
        (map (domain: {
          name = domain;
          value = {
            cert = "${config.security.acme.certs.${domain}.directory}/fullchain.pem";
            private-key = "${config.security.acme.certs.${domain}.directory}/key.pem";
          };
        }))
        builtins.listToAttrs
      ]);
      directory.internal = {
        store = "rocksdb";
        type = "internal";
      };
      server = {
        hostname = "mail.freshly.space";
        tls = {
          enable = true;
          implicit = true;
        };
        listener = {
          smtp = {
            protocol = "smtp";
            bind = "0.0.0.0:25";
          };
          submissions = {
            protocol = "smtp";
            bind = "0.0.0.0:465";
          };
          imaps = {
            protocol = "imap";
            bind = "0.0.0.0:993";
          };
          web = {
            protocol = "http";
            bind = "127.0.0.1:1027";
            url = "https://mail.freshly.space";
          };
        };
      };
      storage = {
        blob = "rocksdb";
        data = "rocksdb";
        directory = "internal";
        fts = "rocksdb";
        lookup = "rocksdb";
      };
      store.rocksdb = {
        compression = "lz4";
        path = "/var/lib/stalwart-mail/data/rocksdb";
        type = "rocksdb";
      };
      tracer.stdout.level = "debug";
    };
  };

  systemd.services.stalwart-mail = {
    wants = [
      "acme-finished-mail.freshly.space.target"
    ]
    ++ (map (domain: "acme-finished-${domain}.target") mail_domains);
    after = [
      "acme-selfsigned-mail.freshly.space.service"
      "acme-mail.freshly.space.service"
    ]
    ++ (map (domain: "acme-selfsigned-${domain}.service") mail_domains)
    ++ (map (domain: "acme-${domain}.service") mail_domains);
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."mail.freshly.space" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "http://127.0.0.1:1027";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };

  security.acme.certs =
    (lib.pipe mail_domains [
      (map (domain: {
        name = domain;
        value = {
          extraDomainNames = [
            "autoconfig.${domain}"
            "autodiscover.${domain}"
            "mta-sts.${domain}"
          ];
          reloadServices = [ "stalwart-mail.service" ];
          webroot = null;
        };
      }))
      builtins.listToAttrs
    ])
    // {
      "mail.freshly.space".reloadServices = [ "stalwart-mail.service" ];
    };

  clicks.storage.impermanence.persist.directories = [ "/var/lib/stalwart-mail" ];
}
