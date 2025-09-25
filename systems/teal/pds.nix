# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  system,
  ...
}:
{
  disabledModules = [ "services/web-apps/pds.nix" ];
  imports = [
    "${project.inputs.nixos-unstable.src}/nixos/modules/services/web-apps/bluesky-pds.nix"
  ];

  nixpkgs.overlays = [
    (final: _prev: {
      bluesky-pdsadmin = final.pdsadmin;
    })
  ];

  services.bluesky-pds = {
    enable = true;
    package = project.packages.bluesky-pds.result.${system};
    settings = {
      PDS_HOSTNAME = "pds.freshly.space";
      PDS_PORT = 1033;
      PDS_SERVICE_HANDLE_DOMAINS = ".at.freshlybakedca.ke";
      PDS_EMAIL_FROM_ADDRESS = "pds@freshly.space";
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
  };

  clicks.storage.impermanence.persist.directories = [ "/var/lib/pds" ];
}
