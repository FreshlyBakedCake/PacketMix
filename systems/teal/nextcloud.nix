# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, pkgs, config, ... }:
{
  users.users.nextcloud = {
    isSystemUser = true;
    createHome = true;
    home = "/var/lib/nextcloud";
    group = "nextcloud";
  };
  users.groups.nextcloud = { };

  services.nextcloud = {
    enable = true;
    https = true;

    config.adminpassFile = "/secrets/nextcloud/adminpass";

    hostName = "nextcloud.clicks.codes";

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
      "overwrite.cli.url" = "https://nextcloud.clicks.codes";
    };

    notify_push.enable = false;
    configureRedis = true;
  };

  services.nginx.virtualHosts."nextcloud.clicks.codes" = {
    enableACME = true;
    addSSL = true;
    acmeRoot = null;

    serverAliases = [ "www.nextcloud.clicks.codes" ];
  };

  systemd.services = {
    nextcloud-setup.requires = [ "postgresql.service" ];
    nextcloud-cron.requires = [ "postgresql.service" ];
    nextcloud-notify_push.requires = [ "postgresql.service" ];
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

  clicks.storage.impermanence.persist.directories = [
    "/var/lib/nextcloud"
    "/var/lib/postgresql"
  ];
}
