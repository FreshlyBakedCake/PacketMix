# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.nextcloud = {
    enable = true;
    https = true;

    config.adminpassFile = builtins.toFile "nextcloud-admin-password" "admin";

    hostName = "nextcloud.dev.redhead.starrysky.fyi";

    package = pkgs.nextcloud31;

    poolSettings = {
      pm = "dynamic";
      "pm.max_children" = "32";
      "pm.max_requests" = "500";
      "pm.max_spare_servers" = "4";
      "pm.min_spare_servers" = "2";
      "pm.start_servers" = "2";
      "listen.owner" = "nextcloud";
      "listen.group" = "nextcloud";
    };
    phpOptions."opcache.interned_strings_buffer" = "32";

    config = {
      dbtype = "pgsql";
      dbhost = "/run/postgresql";
    };

    settings = {
      loglevel = 3;
      social_login_auto_redirect = true;
      default_phone_region = "US";
      "overwrite.cli.url" = "https://nextcloud.dev.redhead.starrysky.fyi";
    };

    notify_push.enable = false;
    configureRedis = true;
  };

  services.nginx.virtualHosts."nextcloud.dev.redhead.starrysky.fyi" = {
    enableACME = true;
    forceSSL = true;
    acmeRoot = null;

    serverAliases = [ "nextcloud.dev.redhead.starrysky.fyi" ];
  };

  security.acme.acceptTerms = true;
  security.acme.certs."nextcloud.dev.redhead.starrysky.fyi" = {
    dnsProvider = "cloudflare";
    environmentFile = "/secrets/acme/environmentFile";
    email = "skyler.grey@collabora.com";
  };
  security.acme.certs."collabora.dev.redhead.starrysky.fyi" = {
    dnsProvider = "cloudflare";
    environmentFile = "/secrets/acme/environmentFile";
    email = "skyler.grey@collabora.com";
  };

  services.nginx.virtualHosts."collabora.dev.redhead.starrysky.fyi" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "https://127.0.0.1:9980";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };

  services.postgresql = {
    enable = true;

    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
    ];
  };

  environment.systemPackages = [ config.services.nextcloud.occ ];

  systemd.targets = {
    nextcloud = { };
    phpfpm.wantedBy = lib.mkForce [ "nextcloud.target" ];
  };

  systemd.services = {
    # By default nextcloud is brought up on multi-user.target... but we only want it on redhead for testing/development
    nextcloud-setup = {
      wantedBy = lib.mkForce [ "nextcloud.target" ];
      partOf = [ "nextcloud.target" ];
      requires = [ "postgresql.service" ];
    };
    nginx = {
      partOf = [ "nextcloud.target" ];
      wantedBy = lib.mkForce [ "nextcloud.target" ];
    };
    nginx-config-reload = {
      wantedBy = lib.mkForce [
        "nextcloud.target"
        "acme-finished-nextcloud.redhead.dev.starrysky.fyi.target"
      ];
      partOf = [ "nextcloud.target" ];
    };
    postgresql = {
      wantedBy = lib.mkForce [ "nextcloud.target" ];
      partOf = [ "nextcloud.target" ];
    };
    redis-nextcloud = {
      wantedBy = lib.mkForce [ "nextcloud.target" ];
      partOf = [ "nextcloud.target" ];
    };
    nextcloud-cron = {
      wantedBy = lib.mkForce [ "nextcloud.target" ];
      partOf = [ "nextcloud.target" ];
      requires = [ "postgresql.service" ];
    };
    nextcloud-notify_push = {
      wantedBy = lib.mkForce [ "nextcloud.target" ];
      partOf = [ "nextcloud.target" ];
      requires = [ "postgresql.service" ];
    };
  };

  clicks.storage.impermanence.persist.directories = [
    "/var/lib/acme"
    "/var/lib/nextcloud"
  ];
}
