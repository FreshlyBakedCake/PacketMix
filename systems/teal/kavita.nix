# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{
  project,
  pkgs,
  config,
  lib,
  ...
}:
{
  disabledModules = [ "services/web-apps/kavita.nix" ];
  imports = [
    "${project.inputs.nixos-unstable.src}/nixos/modules/services/web-apps/kavita.nix"
  ];

  services.kavita = {
    enable = true;
    package = project.packages.packetmix-kavita.result."x86_64-linux";
    tokenKeyFile = "/secrets/kavita/tokenKeyFile";
    settings = {
      Port = 1034;
      OpenIdConnectSettings = {
        Authority = "https://idm.freshly.space/oauth2/openid/kavita";
        ClientId = "kavita";
        Secret = "@OIDC_SECRET@";
        Enabled = true;
        CustomScopes = [
          "groups"
          "openid"
          "profile"
        ];
      };
    };
  };

  systemd.services.kavita = {
    preStart = lib.mkAfter ''
      ${pkgs.replace-secret}/bin/replace-secret '@OIDC_SECRET@' \
      ''${CREDENTIALS_DIRECTORY}/OIDC_SECRET \
      '${config.services.kavita.dataDir}/config/appsettings.json'

      while [[ \"$(${pkgs.curl}/bin/curl -s -L https://idm.freshly.space/status)\" != \"true\" ]]; do sleep 5; done
    '';
    serviceConfig.LoadCredential = [ "OIDC_SECRET:/secrets/kavita/OIDC_SECRET" ];
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."kavita.freshly.space" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "http://127.0.0.1:1034";
      recommendedProxySettings = true;
      extraConfig = "proxy_http_version 1.1;";
    };
  };

  clicks.storage.impermanence.persist.directories = [
    "/var/lib/kavita"
  ];
}
