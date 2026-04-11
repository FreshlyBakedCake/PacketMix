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

    settings = {
      server = {
        host = "127.0.0.1";
        port = 1039;

        hostname = "at.freshly.space";

        available_user_domains = [
          "at.freshly.space"
          "at.freshlybakedca.ke"
        ];

        age_assurance_override = true;
      };

      email = {
        from_name = "Freshly PDS";
        from_address = "pds@freshly.space";
        sendmail_path = "${pkgs.msmtp}/bin/sendmail";
      };

      cache.valkey_url = "unix://${config.services.redis.servers.tranquil-pds.unixSocket}";

      # Our PDS is private
      # Therefore, we have verified the age of everyone on the service is over the age of majority - and we didn't need KWS to do it!

      sso.oidc = {
        enabled = true;
        client_id = "pds";
        client_secret = ""; # Specified in an environment variable - tranquil makes us put it here anyway..?
        issuer = "https://idm.freshly.space/oauth2/openid/pds/";
        display_name = "Freshly IDM";
      };

      firehose.crawlers = [
        "https://bsky.network"
        "https://relay.fire.hose.cam"
        "https://relay3.fr.hose.cam"
        "https://relay.upcloud.world"
        "https://atproto.africa"
        "https://relay1.us-east.bsky.network"
        "https://relay1.us-west.bsky.network"
      ];
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

  # Special handling for an allowlist of repos to un-break anisota proxying. May cause issues elsewhere on atproto, and we want to avoid fixing this for anisota dev who also has an account on our PDS...
  services.nginx.commonHttpConfig = ''
    map $arg_repo $pds_anisota_proxy_header {
      "did%3Aplc%3Auuyqs6y3pwtbteet4swt5i5y" "";
      ~. $http_atproto_proxy;
    }
  '';

  services.nginx.virtualHosts."at.freshly.space" = {
    enableACME = true;
    acmeRoot = null;
    onlySSL = true;

    listenAddresses = [
      "0.0.0.0"
      "[::0]"
    ];

    serverAliases = lib.mkForce [
      "*.at.freshlybakedca.ke"
      "*.at.freshly.space"
    ];

    locations."/" = {
      proxyPass = "http://127.0.0.1:1039";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };

    locations."/xrpc/com.atproto.repo.listRecords" = {
      proxyPass = "http://127.0.0.1:1039";
      recommendedProxySettings = true;
      proxyWebsockets = true;

      extraConfig = ''
        proxy_set_header "atproto-proxy" $pds_anisota_proxy_header;
      '';
    };

    locations."/xrpc/com.atproto.repo.getRecord" = {
      proxyPass = "http://127.0.0.1:1039";
      recommendedProxySettings = true;
      proxyWebsockets = true;

      extraConfig = ''
        proxy_set_header "atproto-proxy" $pds_anisota_proxy_header;
      '';
    };

    extraConfig = ''
      client_max_body_size 10G;
    '';
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
