# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  system,
  ...
}:
{
  services.bluesky-pds = {
    enable = true;
    package = project.packages.packetmix-bluesky-pds.result.${system};
    settings = {
      PDS_HOSTNAME = "pds.freshly.space";
      PDS_PORT = 1033;
      PDS_SERVICE_HANDLE_DOMAINS = ".at.freshlybakedca.ke";
      PDS_EMAIL_FROM_ADDRESS = "pds@freshly.space";
      PDS_BLOB_UPLOAD_LIMIT = "268435456";
    };
    environmentFiles = [
      "/secrets/pds/environmentFile"
    ];
  };

  services.nginx.virtualHosts."pds.freshly.space" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    serverAliases = [ "*.at.freshlybakedca.ke" ];

    locations."/" = {
      proxyPass = "http://127.0.0.1:1033";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };

    locations."/xrpc/app.bsky.ageassurance.getState" = {
      extraConfig = ''
        default_type application/json;
        add_header access-control-allow-headers "authorization,dpop,atproto-accept-labelers,atproto-proxy" always;
        add_header access-control-allow-origin "*" always;
        add_header X-Frame-Options SAMEORIGIN always;
        add_header X-Content-Type-Options nosniff;
      '';
      return = "200 '${
        builtins.toJSON {
          state = {
            lastInitiatedAt = "2025-09-11T19:18:03.551Z";
            status = "assured";
            access = "full";
          };
          metadata.accountCreatedAt = "2023-12-12T20:16:56.499Z";
        }
      }'";
      # Our PDS is private
      # Therefore, we have verified the age of everyone on the service is over the age of majority - and we didn't need KWS to do it!
    };

    extraConfig = ''
      client_max_body_size 1024M;
    '';
  };

  clicks.storage.impermanence.persist.directories = [ "/var/lib/pds" ];
}
