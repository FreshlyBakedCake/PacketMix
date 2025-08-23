# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  pkgs,
  lib,
  config,
  ...
}:
{
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";

    config = {
      # Server Settings
      DOMAIN = "https://vaultwarden.clicks.codes"; # Not moving off the clicks domain due to passkey migration - maybe at a later date...
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 1028;

      # Mail Settings
      SMTP_HOST = "mail.freshly.space";
      SMTP_FROM = "vaultwarden@clicks.codes";
      SMTP_FROM_NAME = "Clicks vaultwarden";
      SMTP_SECURITY = "force_tls";
      SMTP_PORT = 465;
      SMTP_USERNAME = "automated@freshly.space";

      REQUIRE_DEVICE_EMAIL = true;

      # General Settings
      SIGNUPS_ALLOWED = false;
      INVITATIONS_ALLOWED = true;
      SIGNUPS_DOMAINS_WHITELIST = builtins.concatStringsSep "," [
        "a.starrysky.fyi"
        "clicks.codes"
        "freshlybakedca.ke"
        "hopescaramels.com"
        "thecoded.prof"
        "trans.gg"
        "turquoise.fyi"
      ];
      # This is similar to our mail domains, with the following changes
      # - Add trans.gg
      # - Remove special purpose domains
      # - Remove deprecated domains
      # - Deduplicate to a single canonical domain per group
      SIGNUPS_VERIFY = true;

      DISABLE_2FA_REMEMBER = true;

      IP_HEADER = "X-Forwarded-For";

      # YubiKey Settings
      YUBICO_CLIENT_ID = "89788";

      ORG_ENABLE_GROUPS = true;
      # I have looked at the risks. They seem relatively small in comparison
      # to the utility (stuff like sync issues if you don't refresh your page)
      # Additionally, we have run with this in production for a significant
      # amount of time with no noticed adverse effects...

      DATABASE_URL = "postgresql:///vaultwarden?host=/run/postgresql";
    };

    environmentFile = "/secrets/vaultwarden/secrets.env";
  };

  systemd.services.vaultwarden = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "vaultwarden" ];
    ensureUsers = [
      {
        name = "vaultwarden";
        ensureDBOwnership = true;

      }
    ];
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."vaultwarden.clicks.codes" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "http://127.0.0.1:1028";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };

  clicks.storage.impermanence.persist.directories = [
    "/var/lib/postgresql"
    "/var/lib/vaultwarden"
  ];
}
