# SPDX-FileCopyrightText: 2024 Clicks Codes
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
let
  groups = {
    /**
      Users have full access to contact other users or servers

      This gives them access to internal-only things such as all SilverBullet
      notes on https://silverbullet.clicks.codes or finance information on
      https://fava.clicks.codes

      They tend to be either close friends, people who host servers on our
      network or straight-up Clicks or Freshly Baked Cake developers

      Servers are owned by users but have the tag `tag:server` to give them a
      different permission level. Servers can only access other servers
    */
    "group:users" = [
      "coded"
      "matei"
      "minion"
      "pineafan"
      "zanderp25"
      "mostlyturquoise"
    ];

    /**
      Friends only have access to other users

      This doesn't give them access to internal-only services, but it could let
      them join, say, Minecraft servers which are owned by someone else on the
      tailnet
    */
    "group:friends" = [
      "sirdigalot"
    ];
  };

  exceptional_acls = [
    {
      action = "accept";
      src = [ "zulu" ];
      dst = [ "zanderp25:3000" ];
    } # Used to let Zan reverse proxy to their personal machine for development - port-locked so probably OK
    {
      action = "accept";
      src = [ "mostlyturquoise" ];
      dst = [ "tag:mostlyturquoise-minecraft-server:*" ];
    } # Used to let mostlyturquoise and their friends access their minecraft servers without giving people too many permissions
  ];

  acls = [
    {
      action = "accept";
      src = [ "group:users" ];
      dst = [
        "group:users:*"
        "group:friends:*"
        "autogroup:internet:*"
        "tag:server:*"
      ];
    }
    {
      action = "accept";
      src = [ "group:friends" ];
      dst = [
        "group:users:*"
        "group:friends:*"
      ];
    }
    {
      action = "accept";
      src = [ "tag:server" ];
      dst = [ "tag:server:*" ];
    }
  ] ++ exceptional_acls;

  tagOwners = {
    "tag:server" = [ "group:users" ];
    "tag:mostlyturquoise-minecraft-server" = [ "mostlyturquoise" ];
  };
in
{
  # Headscale service
  services.headscale = {
    enable = true;

    address = "127.0.0.1";
    port = 1024;

    settings = {
      server_url = "https://vpn.clicks.codes";
      noise.private_key_path = "/secrets/headscale/noise_private_key";
      policy = {
        mode = "file";
        path = (
          pkgs.writers.writeJSON "tailscale-acls.json" {
            inherit groups acls tagOwners;
          }
        );
      };
      dns = {
        nameservers.global = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
        base_domain = "clicks.domains";
      };
      oidc = {
        only_start_if_oidc_is_available = false; # Otherwise we can end up locking ourselves out...
        strip_email_domain = true;

        issuer = "https://login.clicks.codes/realms/master";

        client_id = "headscale";
        client_secret_path = "/secrets/headscale/oidc_client_secret";

        allowed_groups = [ "/clicks" ];
      };
    };
  };

  # Nginx
  services.nginx.enable = true;
  services.nginx.virtualHosts."vpn.clicks.codes" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    serverAliases = [ "www.vpn.clicks.codes" ];

    locations."/" = {
      proxyPass = "http://127.0.0.1:1024";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };

  # Impermanence
  clicks.storage.impermanence.persist.directories = [ "/var/lib/headscale" ];
}
