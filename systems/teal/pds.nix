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

    extraConfig = ''
      client_max_body_size 1024M;
    '';
  };

  clicks.storage.impermanence.persist.directories = [ "/var/lib/pds" ];
}
