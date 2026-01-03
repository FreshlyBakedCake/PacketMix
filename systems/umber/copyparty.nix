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
  imports = [
    project.inputs.copyparty.result.nixosModules.default
  ];

  config = {
    nixpkgs.overlays = [ project.inputs.copyparty.result.overlays.default ];

    services.copyparty =
      let
        admins = [
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
          idp-h-usr = "X-Webauth-Login";
          idp-adm = admins;
          have-idp-hdrs = 1; # https://github.com/9001/copyparty/issues/849

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

          spinner = "⭐"; # [hopefully this isn't too boring for you, tripflag](https://github.com/9001/copyparty/tree/hovudstraum/docs/rice#boring-loader-spinner)

          xm = "aw,f,j,t3600,${project.inputs.copyparty.src}/bin/hooks/wget.py"; # download URLs that are pasted into the message box

          xff-src = "127.0.0.1";
          rproxy = 1;

          exp = true;
        };

        volumes = {
          "/" = {
            path = "/var/lib/copyparty/data";

            access = {
              r = "*";
              A = admins;
            };
          };
          "/private" = {
            path = "/var/lib/copyparty/private";

            access = {
              A = [
                "minion"
              ];
            };
          };
        };
      };

    systemd.services.copyparty = {
      path = [ pkgs.wget ]; # Needed for downloading files by URL
      serviceConfig = {
        BindReadOnlyPaths = [
          "/etc/ssl"
          "/etc/static/ssl"
        ]; # Required for wget to validate SSL for downloads
        StateDirectory =
          "copyparty "
          + (lib.pipe config.services.copyparty.volumes [
            builtins.attrValues
            (map (mount: mount.path))
            (map (lib.removePrefix "/var/lib/"))
            (lib.concatStringsSep " ")
          ]);
      };
    };

    services.nginx.enable = true;

    services.nginx.virtualHosts."copyparty.starrysky.fyi" = {
      serverName = "copyparty.starrysky.fyi";

      addSSL = true;
      enableACME = true;
      acmeRoot = null;

      locations."/" = {
        proxyPass = "http://127.0.0.1:1030";
        recommendedProxySettings = true;
        proxyWebsockets = true;
      };

      extraConfig = ''
        client_max_body_size 1024M;
      '';
    };
    services.nginx.tailscaleAuth = {
      enable = true;
      virtualHosts = [ "copyparty.starrysky.fyi" ];
    };

    clicks.storage.impermanence.persist.directories = [ "/var/lib/copyparty" ];
  };
}
