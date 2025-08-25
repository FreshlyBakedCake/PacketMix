# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
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
  disabledModules = [ "services/mail/stalwart-mail.nix" ];
  imports = [ "${project.inputs.nixos-unstable.src}/nixos/modules/services/mail/stalwart-mail.nix" ];

  config = {
    services.headscale.settings.dns.extra_records = [
      {
        # mail.freshly.space -> teal
        name = "mail.freshly.space";
        type = "A";
        value = "100.64.0.5";
      }
    ];

    services.stalwart-mail = {
      enable = true;
      openFirewall = true;

      package = project.inputs.nixos-unstable.result.x86_64-linux.stalwart-mail.overrideAttrs {
        inherit (project.inputs.stalwart) src;
        doCheck = false;
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          name = "stalwart-deps";
          inherit (project.inputs.stalwart) src;
          hash = "sha256-t4BLko8vIVHZ44yeQoAhss3OxOlxJCErHm9h+FGG+28=";
        };
      };

      settings = {
        config.local-keys = [
          "store.*"
          "directory.*"
          "tracer.*"
          "!server.blocked-ip.*"
          "!server.allowed-ip.*"
          "server.*"
          "authentication.fallback-admin.*"
          "cluster.*"
          "config.local-keys.*"
          "storage.data"
          "storage.blob"
          "storage.lookup"
          "storage.fts"
          "storage.directory"
          "certificate.*"

          "resolver.public-suffix.*"
          "file-storage.max-size"
          "auth.dkim.sign.*"
          "resolver.type"
          "webadmin.path"
          "webadmin.resource"
          "spam-filter.resource"
        ];
        auth.dkim.sign = "false";
        certificate = {
          "mail.freshly.space" = {
            cert = "%{file:${config.security.acme.certs."mail.freshly.space".directory}/fullchain.pem}%";
            private-key = "%{file:${config.security.acme.certs."mail.freshly.space".directory}/key.pem}%";
            default = true;
          };
        }
        // (lib.pipe mail_domains [
          (map (domain: {
            name = domain;
            value = {
              cert = "%{file:${config.security.acme.certs.${domain}.directory}/fullchain.pem}%";
              private-key = "%{file:${config.security.acme.certs.${domain}.directory}/key.pem}%";
            };
          }))
          builtins.listToAttrs
        ]);
        file-storage.max-size = 8589934592;
        server = {
          hostname = "mail.freshly.space";
          listener = {
            smtp = {
              protocol = "smtp";
              bind = "0.0.0.0:25";
            };
            submissions = {
              protocol = "smtp";
              bind = "0.0.0.0:465";
              tls = {
                enable = true;
                implicit = true;
              };
            };
            imaps = {
              protocol = "imap";
              bind = "0.0.0.0:993";
              tls = {
                enable = true;
                implicit = true;
              };
            };
            web = {
              protocol = "http";
              bind = "127.0.0.1:1027";
              url = "https://mail.freshly.space";
            };
            sieve = {
              protocol = "managesieve";
              bind = "0.0.0.0:4190";
              tls = {
                enable = true;
                implicit = false; # We can't use =true as clients seem to not support it
              };
            };
          };
        };
        http.url = "'https://mail.freshly.space'";
        store.db = {
          type = "postgresql";
          host = "/run/postgresql";
          database = "stalwart-mail";
          query = {
            name = "SELECT name, type, secret, description, quota FROM accounts WHERE name = $1 AND active = true";
            members = "SELECT member_of FROM group_members WHERE name = $1";
            recipients = "SELECT name FROM emails WHERE address = $1 ORDER BY name ASC";
            emails = "SELECT address FROM emails WHERE name = $1 ORDER BY type DESC, address ASC";
          };
        };
        tracer.stdout.level = "debug";
      };
    };

    systemd.services.stalwart-mail = {
      requires = [ "postgresql.service" ];
      wants = [
        "acme-finished-mail.freshly.space.target"
      ]
      ++ (map (domain: "acme-finished-${domain}.target") mail_domains);
      after = [
        "acme-selfsigned-mail.freshly.space.service"
        "acme-mail.freshly.space.service"
        "postgresql.service"
      ]
      ++ (map (domain: "acme-selfsigned-${domain}.service") mail_domains)
      ++ (map (domain: "acme-${domain}.service") mail_domains);
      serviceConfig.RestrictAddressFamilies = lib.mkForce [ ]; # We need the default restricted address families to access the postgres socket
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts =
      lib.pipe
        (
          [ "mail.freshly.space" ]
          ++ (map (domain: [
            "autoconfig.${domain}"
            "autodiscover.${domain}"
            "mta-sts.${domain}"
          ]) mail_domains)
        )
        [
          lib.flatten
          (map (domain: {
            name = domain;
            value = {
              addSSL = true;
              enableACME = true;
              acmeRoot = null;

              locations."/" = {
                proxyPass = "http://127.0.0.1:1027";
                recommendedProxySettings = true;
                proxyWebsockets = true;
              };

              extraConfig = ''
                client_max_body_size 1024M;
              '';
            };
          }))
          builtins.listToAttrs
        ];

    security.acme.certs =
      (lib.pipe mail_domains [
        (map (domain: {
          name = domain;
          value = {
            group = "nginx+stalwart-mail";
            extraDomainNames = [
              "autoconfig.${domain}"
              "autodiscover.${domain}"
              "mta-sts.${domain}"
            ];
            reloadServices = [ "stalwart-mail.service" ];
          };
        }))
        builtins.listToAttrs
      ])
      // {
        "mail.freshly.space" = {
          reloadServices = [ "stalwart-mail.service" ];
          group = "nginx+stalwart-mail";
        };
      };

    users.groups."nginx+stalwart-mail".members = [
      "nginx"
      "stalwart-mail"
    ];

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "stalwart-mail" ];
      ensureUsers = [
        {
          name = "stalwart-mail";
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
