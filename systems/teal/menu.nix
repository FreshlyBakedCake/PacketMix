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
  users.users.menu = {
    isSystemUser = true;
    group = "menu";
  };
  users.groups.menu = { };

  systemd.services.menu = {
    wantedBy = [ "default.target" ];
    script = ''
      ${project.packages.menu.result.${system}}/bin/menu
    '';
    serviceConfig = {
      User = "menu";
      Group = "menu";
      PrivateTmp = true;
    };
    environment.BIND_ADDR = "127.0.0.1:1038";
  };

  services.headscale.settings.dns.extra_records = [
    {
      # go.search.freshly.space -> teal
      name = "go.search.freshly.space";
      type = "A";
      value = "100.64.0.5";
    }
    {
      # menu.freshlybakedca.ke -> teal
      name = "menu.freshlybakedca.ke";
      type = "A";
      value = "100.64.0.5";
    }
  ];

  services.nginx.virtualHosts."menu.freshlybakedca.ke" = {
    listenAddresses = [
      "0.0.0.0"
      "[::0]"
    ];

    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    serverAliases = [ "go.search.freshly.space" ];

    locations."/" = {
      proxyPass = "http://127.0.0.1:1038";
      recommendedProxySettings = true;
      proxyWebsockets = true;

      extraConfig = ''
        proxy_set_header X-Webauth-Login "";
      ''; # TODO: consider setting up oauth2-proxy for internal routes (most of _ except for search) so hyperneutrino/other people who don't have TS on all devices can still use this properly
    };
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."internal.menu.freshlybakedca.ke" = {
    listenAddresses = [ "localhost.tailscale" ];

    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    serverName = "menu.freshlybakedca.ke";

    serverAliases = [ "go.search.freshly.space" ];

    locations."/" = {
      proxyPass = "http://127.0.0.1:1038";
      recommendedProxySettings = true;
    };
  };

  services.nginx.virtualHosts."go" = {
    listenAddresses = [ "localhost.tailscale" ];

    locations."/" = {
      proxyPass = "http://127.0.0.1:1038";
      recommendedProxySettings = true;
    };
  };

  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [
      "internal.menu.freshlybakedca.ke"
      "go"
    ];
  };
}
