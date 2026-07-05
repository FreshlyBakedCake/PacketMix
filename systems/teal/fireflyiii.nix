{ config, lib, ... }:
{
  services.firefly-iii = {
    enable = true;

    enableNginx = true;
    virtualHost = "local.accounting.freshly.space";

    settings = {
      APP_URL = "https://accounting.freshly.space";
      TRUSTED_PROXIES = "*";

      APP_ENV = "production";
      APP_KEY_FILE = "/secrets/fireflyiii/app-key.txt";
      SITE_OWNER = "firefly-admin@freshlybakedca.ke"; # Shown in error messages to users who aren't admin - alias to coded, minion. Not firefly@ since as that would be too easily confusable with the outbound firefly@freshly.space mail

      TZ = "Etc/UTC";

      DB_CONNECTION = "pgsql";
      DB_DATABASE = "firefly-iii";

      MAIL_MAILER = "smtp";
      MAIL_HOST = "mail.freshly.space";
      MAIL_PORT = 587;
      MAIL_FROM = "firefly@freshly.space";
      MAIL_USERNAME = "automated@freshly.space";
      MAIL_PASSWORD_FILE = "/secrets/fireflyiii/mail-pass.txt";
      MAIL_ENCRYPTION = "tls";

      AUTHENTICATION_GUARD = "remote_user_guard";
      AUTHENTICATION_GUARD_HEADER = "HTTP_X_WEBAUTH_LOGIN";
    };
  };
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "firefly-iii" ];
    ensureUsers = [
      {
        name = "firefly-iii";
        ensureDBOwnership = true;
      }
    ];
  };

  services.nginx.virtualHosts."local.accounting.freshly.space" = {
    listenAddresses = [ "localhost" ];
    serverName = "accounting.freshly.space";
  };

  services.nginx.virtualHosts."accounting.freshly.space" = {
    listenAddresses = [ "localhost.tailscale" ];

    forceSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/".proxyPass = "http://127.0.0.1";
  };

  services.nginx.virtualHosts."share.accounting.freshly.space" = {
    listenAddresses = [ "localhost.tailscale" ];

    forceSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "http://127.0.0.1";

      recommendedProxySettings = false;

      extraConfig = ''
        proxy_redirect          off;
        proxy_connect_timeout   ${config.services.nginx.proxyTimeout};
        proxy_send_timeout      ${config.services.nginx.proxyTimeout};
        proxy_read_timeout      ${config.services.nginx.proxyTimeout};
        proxy_http_version      1.1;
        proxy_set_header Connection         "";
        proxy_set_header X-Webauth-Login    "freshlybakedcake";
        proxy_set_header Host               "accounting.freshly.space";
        proxy_set_header X-Real-IP          $remote_addr;
        proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto  $scheme;
        proxy_set_header X-Forwarded-Host   $host;
        proxy_set_header X-Forwarded-Server $hostname;
      ''; # Basically recommendedProxySettings, but with a static Host header that is notably not the actual hostname... -> the links do not seem to be wrong, but I am slightly worried about if somewhere we'll find something which brings us back to the main instance...
    };
  };

  containers.minion-firefly-iii-data-importer = {
    autoStart = true;

    privateNetwork = false;

    bindMounts."/secrets/fireflyiii/minion-data-importer-token.txt".isReadOnly = true;
    bindMounts."/var/lib/firefly-iii-data-importer/minion" = {
      isReadOnly = false;
      mountPoint = "/var/lib/firefly-iii-data-importer";
    };

    config = {
      users.users."firefly-iii-data-importer".uid = 999;

      networking.hosts."127.0.0.1" = [ "accounting.freshly.space" ];

      services.firefly-iii-data-importer = {
        enable = true;

        enableNginx = true;
        virtualHost = "import.accounting.freshly.space";

        settings = {
          TRUSTED_PROXIES = "*";

          FIREFLY_III_URL = "http://accounting.freshly.space";
          VANITY_URL = "https://accounting.freshly.space";

          FIREFLY_III_ACCESS_TOKEN_FILE = "/secrets/fireflyiii/minion-data-importer-token.txt";
        };
      };

      services.nginx.virtualHosts."import.accounting.freshly.space".listen = [
        {
          addr = "127.0.0.1";
          port = 1041;
        }
      ];
    };
  };

  containers.coded-firefly-iii-data-importer = {
    autoStart = true;

    privateNetwork = false;

    bindMounts."/secrets/fireflyiii/coded-data-importer-token.txt".isReadOnly = true;
    bindMounts."/var/lib/firefly-iii-data-importer/coded" = {
      isReadOnly = false;
      mountPoint = "/var/lib/firefly-iii-data-importer";
    };

    config = {
      users.users."firefly-iii-data-importer".uid = 999;

      networking.hosts."127.0.0.1" = [ "accounting.freshly.space" ];

      services.firefly-iii-data-importer = {
        enable = true;

        enableNginx = true;
        virtualHost = "import.accounting.freshly.space";

        settings = {
          TRUSTED_PROXIES = "*";

          FIREFLY_III_URL = "http://accounting.freshly.space";
          VANITY_URL = "https://accounting.freshly.space";

          FIREFLY_III_ACCESS_TOKEN_FILE = "/secrets/fireflyiii/coded-data-importer-token.txt";
        };
      };

      services.nginx.virtualHosts."import.accounting.freshly.space".listen = [
        {
          addr = "127.0.0.1";
          port = 1042;
        }
      ];
    };
  };

  services.nginx.virtualHosts."403.import.accounting.freshly.space" = {
    serverName = "import.accounting.freshly.space";

    listen = [
      {
        addr = "127.0.0.1";
        port = 403;
      }
    ];
    locations."/".return =
      ''403 "403 - Access Denied: Your device is logged on to tailscale as '$http_x_webauth_user', but you haven't been allocated an importer. Please ask the admin mailing list at firefly-admin@freshlybakedca.ke to set one up for you"'';
  };

  services.nginx.commonHttpConfig = ''
    map $auth_user $import_accounting_upstream {
      default 127.0.0.1:403;
      minion 127.0.0.1:1041;
      coded 127.0.0.1:1042;
    }
  '';

  services.nginx.virtualHosts."import.accounting.freshly.space" = {
    listenAddresses = [ "localhost.tailscale" ];

    forceSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "http://$import_accounting_upstream";
      recommendedProxySettings = true;

      extraConfig = ''
        auth_request /auth;
        auth_request_set $auth_user $upstream_http_tailscale_user;
        auth_request_set $auth_name $upstream_http_tailscale_name;
        auth_request_set $auth_login $upstream_http_tailscale_login;
        auth_request_set $auth_tailnet $upstream_http_tailscale_tailnet;
        auth_request_set $auth_profile_picture $upstream_http_tailscale_profile_picture;

        proxy_set_header X-Webauth-User "$auth_user";
        proxy_set_header X-Webauth-Name "$auth_name";
        proxy_set_header X-Webauth-Login "$auth_login";
        proxy_set_header X-Webauth-Tailnet "$auth_tailnet";
        proxy_set_header X-Webauth-Profile-Picture "$auth_profile_picture";
      '';
    };

    locations."= /auth" = {
      # The NixOS module here defaults to /auth, which kills all URLs starting with that... config options copied for compatibility
      extraConfig = ''
        internal;

        proxy_pass http://unix:${config.services.tailscaleAuth.socketPath};
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";

        proxy_set_header Host $host;
        proxy_set_header Remote-Addr $remote_addr;
        proxy_set_header Remote-Port $remote_port;
        proxy_set_header Original-URI $request_uri;
        proxy_set_header X-Scheme $scheme;
        proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;
      '';
    };
  };

  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [
      "accounting.freshly.space"
      # "import.accounting.freshly.space" : NOT THIS because NixOS breaks all routes starting with /auth in this case...
    ];
  };

  clicks.storage.impermanence.persist.directories = [
    "/var/lib/firefly-iii"
    "/var/lib/firefly-iii-data-importer"
  ];
}
