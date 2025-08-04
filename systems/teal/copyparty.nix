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
          idp-h-usr = "X-Webauth-Login";
          idp-adm = admins;

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

        volumes = {
          "/" = {
            path = "/var/lib/copyparty/data";

            access = {
              r = "*";
              A = admins;
            };
          };
          "/users/_" = {
            path = "/var/lib/copyparty/data/users/_";

            access = { };
          };
          "/users/\${u}" = {
            path = "/var/lib/copyparty/data/users/_/\${u}";

            access = {
              A = "\${u}";
            };
          };
          "/groups/freshly" = {
            path = "/var/lib/copyparty/data/groups/freshly";

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
    services.nginx.additionalModules = [ pkgs.nginxModules.lua ];
    services.nginx.appendHttpConfig = ''
      lua_package_path "${
        "${pkgs.luaPackages.lua-resty-core}/lib/lua/5.2/?.lua;"
        + "${pkgs.luaPackages.lua-resty-lrucache}/lib/lua/5.2/?.lua;"
        + "${project.packages.lua-multipart.result.x86_64-linux}/share/lua/5.2/?.lua;;"
      }"; # The double-semicolon makes the default search paths also be included
    '';
    services.nginx.virtualHosts."files.freshly.space" = {
      addSSL = true;
      enableACME = true;
      acmeRoot = null;

      locations."/" = {
        proxyPass = "http://127.0.0.1:1030";
        recommendedProxySettings = true;
        proxyWebsockets = true;

        extraConfig = ''
          proxy_hide_header X-Webauth-Login;
          proxy_set_header X-Webauth-Login $preferred_username;

          proxy_intercept_errors on;
          error_page 403 = @redirectToAuth2ProxyLogin;

          access_by_lua_block {
            if ngx.var.request_uri:sub(-3) == "/?h" and ngx.var.user == "" then
              return ngx.redirect("https://files.freshly.space/oauth2/start?rd=" .. ngx.var.scheme .. "://" .. ngx.var.host .. ngx.var.request_uri, ngx.HTTP_MOVED_TEMPORARILY)
            end

            local headers, err = ngx.req.get_headers()
            if not headers["Content-Type"] then
              return
            end
            
            ngx.req.read_body()
            local body = ngx.req.get_body_data()

            if not body then
              return
            end

            local Multipart = require("multipart")
            local multipart_data = Multipart(body, headers["Content-Type"])

            if multipart_data:get("act").value == "logout" then
              return ngx.redirect("https://files.freshly.space/oauth2/sign_out?rd=" .. ngx.var.scheme .. "://" .. ngx.var.host .. ngx.var.request_uri, ngx.HTTP_MOVED_TEMPORARILY)
            end
          }
        '';
      };

      locations."@empty" = {
        return = "200";
      };

      locations."= /oauth2/auth" = {
        extraConfig = ''
          proxy_intercept_errors on;
          error_page 401 =200 @empty; # We always want to return 200 so as to allow anon access...
        '';
      };

      extraConfig = ''
        auth_request_set $preferred_username $upstream_http_x_auth_request_preferred_username;
      '';
    };

    services.oauth2-proxy = {
      enable = true;

      keyFile = "/secrets/copyparty/oauth2-proxy";

      httpAddress = "http://127.0.0.1:1031";
      nginx = {
        domain = "files.freshly.space";
        virtualHosts."files.freshly.space" = { };
      };
      reverseProxy = true;

      provider = "oidc";
      scope = "openid profile email";
      clientID = "copyparty";

      setXauthrequest = true;

      email.domains = [ "*" ];

      oidcIssuerUrl = "https://idm.freshly.space/oauth2/openid/copyparty";

      extraConfig = {
        skip-provider-button = "true";
        whitelist-domain = "files.freshly.space";
      };
    };
    systemd.services.oauth2-proxy = {
      after = [ "kanidm.service" ];
      requires = [ "kanidm.service" ];
      preStart = "while [[ \"$(${pkgs.curl}/bin/curl -s -L https://idm.freshly.space/status)\" != \"true\" ]]; do sleep 5; done";
    };

    services.headscale.settings.dns.extra_records = [
      {
        # files.freshly.space -> teal
        name = "files.freshly.space";
        type = "A";
        value = "100.64.0.5";
      }
    ];
    services.nginx.virtualHosts."internal.files.freshly.space" = {
      listenAddresses = [ "100.64.0.5" ];

      serverName = "files.freshly.space";

      addSSL = true;
      enableACME = true;
      acmeRoot = null;

      locations."/" = {
        proxyPass = "http://127.0.0.1:1030";
        recommendedProxySettings = true;
        proxyWebsockets = true;
      };
    };
    services.nginx.tailscaleAuth = {
      enable = true;
      virtualHosts = [ "internal.files.freshly.space" ];
    };

    clicks.storage.impermanence.persist.directories = [ "/var/lib/copyparty" ];
  };
}
