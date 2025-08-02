# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  config,
  lib,
  ...
}:
{
  imports = [
    project.inputs.copyparty.result.nixosModules.default
  ];

  config = {
    nixpkgs.overlays = [ project.inputs.copyparty.result.overlays.default ];

    services.copyparty =
      let
        admins = [
          "coded"
          "minion"
        ];
      in
      {
        enable = true;

        settings = {
          i = "127.0.0.1"; # ip
          p = 1030; # port

          # we'll be using nginx for this...
          http-only = true;
          no-crt = true;

          idp-store = 3;

          shr = "/share";
          shr-db = "/var/lib/copyparty/shares.db";
          shr-adm = admins;

          # as we might have private directories, better to be a bit conservative about permissions...
          chmod-f = 700;
          chmod-d = 700;

          magic = true; # "enable filetype detection on nameless uploads"

          e2dsa = true; # index files to allow searching, upload undo, etc.
          e2ts = true; # and scan metadata...

          rss = true; # allow (experimental) rss support -> useful for antennapod/miniflux/co.
          dav-auth = true; # "force auth for all folders" notably "(required by davfs2 when only some folders are world-readable)"

          xvol = true; # don't allow symlinks to break out of confinement...
          no-robots = true; # not really meant to be indexed. Maybe we want to add anubis at some point too...

          ah-alg = "argon2";

          og = true; # opengraph support for the benefit of Discord
          og-ua = "Discordbot";
          og-site = "Freshly Baked Cake Files";
          spinner = "🧁"; # [hopefully this isn't too boring for you, tripflag](https://github.com/9001/copyparty/tree/hovudstraum/docs/rice#boring-loader-spinner)
        };

        accounts = {
          coded.passwordFile = "/secrets/copyparty/default_password_coded";
          minion.passwordFile = "/secrets/copyparty/default_password_minion";
        };

        volumes = {
          "/" = {
            path = "/var/lib/copyparty/data";

            access = {
              r = "*";
              A = admins;
            };
          };
          "/coded" = {
            path = "/var/lib/copyparty/data/coded";

            access = {
              A = "coded";
            };
          };
          "/minion" = {
            path = "/var/lib/copyparty/data/minion";

            access = {
              A = "minion";
            };
          };
          "/freshly" = {
            path = "/var/lib/copyparty/data/freshly";

            access = {
              A = [
                "coded"
                "minion"
              ];
            };
          };
        };
      };

    systemd.services.copyparty.serviceConfig.StateDirectory =
      "copyparty "
      + (lib.pipe config.services.copyparty.volumes [
        builtins.attrValues
        (map (mount: mount.path))
        (map (lib.removePrefix "/var/lib/"))
        (lib.concatStringsSep " ")
      ]);

    services.nginx.enable = true;
    services.nginx.virtualHosts."files.freshly.space" = {
      addSSL = true;
      enableACME = true;
      acmeRoot = null;

      locations."/" = {
        proxyPass = "http://127.0.0.1:1030";
        recommendedProxySettings = true;
        proxyWebsockets = true;
      };
    };

    clicks.storage.impermanence.persist.directories = [ "/var/lib/copyparty" ];
  };
}
