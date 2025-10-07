# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  system,
  config,
  ...
}:
{
  clicks.storage.impermanence.persist.directories = [
    {
      directory = config.services.silverbullet.spaceDir;
      mode = "0700";
      defaultPerms.mode = "0700";
    }
  ];

  services.silverbullet = {
    enable = true;
    listenPort = 1024;
    listenAddress = "127.0.0.1";
    package = project.inputs.nixos-unstable.result.${system}.silverbullet;
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."silverbullet.starrysky.fyi" = {
    listenAddresses = [ "localhost.tailscale" ];

    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    serverAliases = [ "umber.clicks.domains" ];

    locations."/" = {
      proxyPass = "http://$silverbullet_upstream_minion_only";
      recommendedProxySettings = true;
    };
  };

  services.nginx.virtualHosts."silverbullet_access_denied" = {
    listen = [
      {
        addr = "127.0.0.1";
        port = 403;
      }
    ];
    locations."/".return =
      ''403 '403 - Access Denied: Your device is logged on to tailscale as '$http_x_webauth_user'. Unfortunately, this is a private silverbullet instance for 'minion', please use https://silverbullet.clicks.codes instead' '';
  };

  services.nginx.commonHttpConfig = ''
    map $auth_user $silverbullet_upstream_minion_only {
      default 127.0.0.1:403;
      minion 127.0.0.1:1024;
    }
  '';

  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [ "silverbullet.starrysky.fyi" ];
  };
}
