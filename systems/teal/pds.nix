# SPDX-FileCopyrightText: 2026 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  config,
  system,
  pkgs,
  lib,
  ...
}:
{
  imports = [ project.inputs.tranquil-pds.result.nixosModules.default ];

  services.tranquil-pds = {
    enable = true;
    environmentFiles = [
      "/secrets/pds/environmentFile"
    ];

    database.createLocally = true;

    nginx.enable = true;

    settings = {
      SERVER_HOST = "127.0.0.1";
      SERVER_PORT = 1039;

      PDS_HOSTNAME = "at.freshly.space";

      MAIL_FROM_NAME = "Freshly PDS";
      MAIL_FROM_ADDRESS = "pds@freshly.space";
      SENDMAIL_PATH = "${pkgs.msmtp}/bin/sendmail";

      VALKEY_URL = "unix://${config.services.redis.servers.tranquil-pds.unixSocket}";

      BACKUP_ENABLED = "true";

      ACCEPTING_REPO_IMPORTS = "true";

      INVITE_CODE_REQUIRED = "true";
      AVAILABLE_USER_DOMAINS = "at.freshly.space,at.freshlybakedca.ke";
      ENABLE_SELF_HOSTED_DID_WEB = "false";

      PDS_AGE_ASSURANCE_OVERRIDE = "true";
      # Our PDS is private
      # Therefore, we have verified the age of everyone on the service is over the age of majority - and we didn't need KWS to do it!

      SSO_OIDC_ENABLED = "true";
      SSO_OIDC_CLIENT_ID = "pds";
      SSO_OIDC_ISSUER = "https://idm.freshly.space/oauth2/openid/pds/";
      SSO_OIDC_NAME = "Freshly IDM";
    };
  };

  services.redis.package = pkgs.valkey;
  services.redis.servers.tranquil-pds = {
    enable = true;
    appendOnly = true;
    user = "tranquil-pds";
  };

  systemd.services.tranquil-pds = {
    wants = [ "redis-tranquil-pds.service" ];
    after = [ "redis-tranquil-pds.service" ];

    environment = {
      XDG_CONFIG_HOME = "/secrets/pds";
    };

    serviceConfig.StateDirectory = [
      "tranquil-pds/blobs"
      "tranquil-pds/backups"
    ]; # Not created automatically by tranquil for some reason...
  };

  services.nginx.virtualHosts."at.freshly.space" = {
    acmeRoot = null;

    serverAliases = lib.mkForce [
      "*.at.freshlybakedca.ke"
      "*.at.freshly.space"
    ];
  };

  services.nginx.virtualHosts."pds.freshly.space" = {
    enableACME = true;
    acmeRoot = null;
    addSSL = true;

    locations."/" = {
      return = "308 https://at.freshly.space$request_uri";
    };
  };

  clicks.storage.impermanence.persist.directories = [ "/var/lib/tranquil-pds" ];
}
