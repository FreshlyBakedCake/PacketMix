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
    listenPort = 1026;
    listenAddress = "127.0.0.1";
    package = project.inputs.nixos-unstable.result.${system}.silverbullet;
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."silverbullet.clicks.codes" = {
    listenAddresses = [ "localhost.tailscale" ];

    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    serverAliases = [ "www.silverbullet.clicks.codes" ];

    locations."/" = {
      proxyPass = "http://127.0.0.1:1026";
      recommendedProxySettings = true;
    };
  };

  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [ "silverbullet.clicks.codes" ];
  };
}
