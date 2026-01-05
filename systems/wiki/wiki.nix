# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
# SPDX-FileCopyrightText: 2026 Collabora Productivity Limited
#
# SPDX-License-Identifier: MIT

# This ingredient has some default values (including OIDC config/etc.) that make it probably unsuitable for use outside of Freshly Baked. Sorry.
{
  project,
  system,
  config,
  pkgs,
  lib,
  ...
}:
{
  options.ingredient.wiki.wiki = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "What should your wiki be called";
      default = "Freshly Wiki";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Where your wiki should be hosted";
    };
    email = lib.mkOption {
      type = lib.types.str;
      description = "What email should notifications/password resets/etc. come from";
    };
    enablePublicInternet = lib.mkEnableOption "Allow access from the public internet with authentication via OIDC";
    enableAutoRegistration = lib.mkEnableOption "Allow unregistered users to automatically register via OIDC or Tailscale";
  };

  config = {
    clicks.storage.impermanence.persist.directories = [
      {
        directory = "/var/lib/mediawiki";
        mode = "0700";
        user = "mediawiki";
        defaultPerms.mode = "0700";
      }
      {
        directory = "/var/lib/private/opensearch";
        mode = "0700";
        user = "opensearch";
        defaultPerms.mode = "0700";
      }
    ];

    services.mediawiki = {
      enable = true;
      package = project.inputs.nixos-unstable.result.${system}.mediawiki; # header auth master requires mediawiki unstable - header auth stable is broken on missing Hooks (recently removed in stable MW version)
      phpPackage = pkgs.php83.withExtensions ({ enabled, all }: enabled ++ [ all.luasandbox ]);
      database.type = "postgres";
      path = [
        pkgs.diffutils
        pkgs.imagemagick
        pkgs.python3Packages.pygments
      ];
      extensions = {
        AdvancedSearch = project.inputs.AdvancedSearch.src;
        Auth_remoteuser = project.inputs.Auth_remoteuser.src; # header auth
        AutoCreateCategoryPages = project.inputs.AutoCreateCategoryPages.src;
        Cargo = project.inputs.Cargo.src; # queries and soforth
        CategoryTree = null;
        CheckUser = null;
        Cite = null;
        CiteThisPage = null;
        CirrusSearch = "${
          pkgs.php.buildComposerProject {
            pname = "CirrusSearch";
            version = "0.0.3665";
            src = project.inputs.CirrusSearch.src;
            vendorHash = "sha256-MLD/3hvzX1aqR4knajJ1amb6K5SVtxlfy+UZWoSi1Bk=";
            composerLock = ./wiki/CirrusSearch.composer.lock;
          }
        }/share/php/CirrusSearch"; # needed for advancedsearch
        CodeEditor = null;
        DiscussionTools = null;
        Echo = null;
        EditNotify = project.inputs.EditNotify.src;
        Elastica = "${
          pkgs.php.buildComposerProject {
            pname = "Elastica";
            version = "0.0.3665";
            src = project.inputs.Elastica.src;
            vendorHash = "sha256-4kp8njLTqPeFCREnGharCB/pmYBnXLJR4TdD6EH6WCI=";
            composerLock = ./wiki/Elastica.composer.lock;
          }
        }/share/php/Elastica"; # needed for cirrussearch
        Linter = null;
        Math = null;
        MobileFrontend = project.inputs.MobileFrontend.src;
        NamespacePreload = project.inputs.NamespacePreload.src;
        Network = "${
          config.services.phpfpm.pools.mediawiki.phpPackage.buildComposerProject {
            pname = "Network";
            version = "0.0.3665";
            src = project.inputs.Network.src;
            vendorHash = "sha256-JHa6PW5xO3pcwn/2jbGXM0wGhr6UmtqFdxaGCgpaYb0=";
            composerLock = ./wiki/Network.composer.lock;
          }
        }/share/php/Network"; # for page connection graphs
        OpenIDConnect = lib.mkIf config.ingredient.wiki.wiki.enablePublicInternet "${
          pkgs.php.buildComposerProject {
            pname = "OpenIDConnect";
            version = "0.0.3665";
            src = project.inputs.OpenIDConnect.src;
            vendorHash = "sha256-DjxyOK21tbBEj6hFfhVNDxeNu4a26hvMRHgD/u24ZT0=";
            composerLock = ./wiki/OpenIDConnect.composer.lock;

            postInstall = ''
              cat sql/postgres/ChangePrimaryKey.sql | sed 's/DROP  INDEX "primary"/ALTER TABLE openid_connect DROP CONSTRAINT openid_connect_pkey/' > $out/share/php/OpenIDConnect/sql/postgres/ChangePrimaryKey.sql
            '';
          }
        }/share/php/OpenIDConnect";
        ParserFunctions = null;
        PluggableAuth = lib.mkIf config.ingredient.wiki.wiki.enablePublicInternet project.inputs.PluggableAuth.src; # needed for OIDC
        Poem = null;
        ReplaceText = null;
        Scribunto = null;
        SecureLinkFixer = null;
        SimpleTooltip = project.inputs.SimpleTooltip.src;
        SyntaxHighlight_GeSHi = null;
        TemplateData = null;
        TemplateStyles = null;
        Thanks = null;
        UserMerge = project.inputs.UserMerge.src;
        VisualEditor = null;
        WikiEditor = null;
      };
      extraConfig = ''
        $wgMaxUploadSize = 1024*1024*1024*8;
        $wgGroupPermissions['autoconfirmed']['upload_by_url'] = true;
        $wgGroupPermissions['autoconfirmed']['interwiki'] = true; // Special:Interwiki - edit shortlink prefixes, crazy-strong permission but we trust our friends
        $wgAllowCopyUploads = true;
        $wgCopyUploadsFromSpecialUpload = true;

        $wgSMTP = [
          'host'      => 'ssl://mail.freshly.space',
          'IDHost'    => '${config.ingredient.wiki.wiki.hostname}',
          'localhost' => '${config.ingredient.wiki.wiki.hostname}',
          'port'      => 465,
          'auth'      => true,
          'username'  => 'automated@freshly.space',
          'password'  => trim(file_get_contents('/secrets/mediawiki/mail_password.txt'))
        ];
        $wgLocalInterwikis = [
          'fbc'
        ];

        $wgWhitelistReadRegexp = [
          '/^Main Page$/',
          '/^Public:/',
          '/^User:/'
        ];
        $wgGroupPermissions['*']['read'] = false;
        $wgGroupPermissions['*']['edit'] = false;
        $wgGroupPermissions['*']['createaccount'] = false;
        $wgGroupPermissions['*']['autocreateaccount'] = ${
          if config.ingredient.wiki.wiki.enableAutoRegistration then "true" else "false"
        };

        $wgGroupPermissions['bureaucrat']['usermerge'] = true;

        $wgAuthRemoteuserUserName = function () {
          if (!isset($_SERVER['HTTP_X_WEBAUTH_LOGIN'])) {
            return "";
          }

          if ($_SERVER['HTTP_X_WEBAUTH_LOGIN'] === 'hyperneutrino') {
            return 'HyperNeutrino';
          }

          return $_SERVER['HTTP_X_WEBAUTH_LOGIN'];
        };
        $wgAuthRemoteuserPriority = MediaWiki\Session\SessionInfo::MAX_PRIORITY;

        $wgUseCdn = true;
        $wgCdnServersNoPurge = [
          '127.0.0.1'
        ];
        $wgUsePrivateIPs = true;

        $wgUseInstantCommons = true;
        $wgPingback = false;

        ${
          if config.ingredient.wiki.wiki.enablePublicInternet then
            ''
              $wgPluggableAuth_Config = [
                'Freshly Baked Cake Kanidm' => [
                  'plugin' => 'OpenIDConnect',
                  'data' => [
                    'providerURL' => 'https://idm.freshly.space/oauth2/openid/mediawiki',
                    'clientID' => 'mediawiki',
                    'clientsecret' => trim(file_get_contents('/secrets/mediawiki/oidc_client_secret.txt')),
                    'codeChallengeMethod' => 'S256'
                  ]
                ]
              ];
            ''
          else
            ""
        }

        $wgOpenIDConnect_MigrateUsersByUserName = true;

        $wgLogos = [
          'icon' => '/icon.svg',
          'svg' => '/icon.svg'
        ];

        $wgPygmentizePath = '${pkgs.python3Packages.pygments}/bin/pygmentize';

        $wgScribuntoDefaultEngine = 'luasandbox';

        $wgNamespacesWithSubpages[NS_MAIN] = true;

        $wgNamespacePreloadDoExpansion = false; // This can't expand {{PAGENAME}} (or like) correctly, making it very nearly useless

        $wgCirrusSearchServers = [
          [
            "host" => '127.0.0.1',
            "port" => 1037
          ]
        ];
        $wgSearchType = 'CirrusSearch';
        $wgNamespacesToBeSearchedDefault[NS_CATEGORY] = true;

        $wgUrlProtocols[] = "rad:";

        $wgSVGNativeRendering = true;

        $wgRCWatchCategoryMembership = true;

        $wgCargoPageDataColumns[] = 'creationDate';
        $wgCargoPageDataColumns[] = 'modificationDate';
        $wgCargoPageDataColumns[] = 'creator';
        $wgCargoPageDataColumns[] = 'lastEditor';
        $wgCargoPageDataColumns[] = 'displayTitle';
        $wgCargoPageDataColumns[] = 'categories';
        $wgCargoPageDataColumns[] = 'numRevisions';
        $wgCargoPageDataColumns[] = 'outgoingLinks';
        $wgCargoPageDataColumns[] = 'isRedirect';
        $wgCargoPageDataColumns[] = 'pageNameOrRedirect';
        $wgCargoPageDataColumns[] = 'pageIDOrRedirect';

        $wgCargoFileDataColumns[] = 'mediaType';
        $wgCargoFileDataColumns[] = 'path';
        $wgCargoFileDataColumns[] = 'lastUploadDate';

        $wgFixDoubleRedirects = true;

        $wgMFAutodetectMobileView = true;
        $wgMFEnableMobilePreferences = true;
        wfLoadSkin( 'MinervaNeue' );

        $wgShowExceptionDetails = true;
        $wgDevelopmentWarnings = true;
      '';
      webserver = "nginx";
      url = "https://${config.ingredient.wiki.wiki.hostname}";
      nginx.hostName = config.ingredient.wiki.wiki.hostname;
      inherit (config.ingredient.wiki.wiki) name;
      database = {
        passwordFile = builtins.toFile "unused-mediawiki-postgress-password" "userpass"; # This isn't actually needed for running a wiki, but some of the initialization scripts do require it. It's not a real password.
        createLocally = false; # We can't use createLocally with passwordFile, which is needed during initialization... we'll ensure the database ourself below :(

        socket = "/run/postgresql";
      };

      passwordSender = config.ingredient.wiki.wiki.email;

      passwordFile = "/secrets/mediawiki/initial_admin_password.txt";
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ config.services.mediawiki.database.name ];
      ensureUsers = [
        {
          name = config.services.mediawiki.database.user;
          ensureDBOwnership = true;
        }
      ];
    };
    systemd.services.mediawiki-init.after = [ "postgresql.target" ];
    systemd.services.httpd.after = [ "postgresql.target" ];

    systemd.timers.mediawiki-maintenance = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnUnitActiveSec = "30";
        OnBootSec = "30";
        Persistent = false;
        Unit = "mediawiki-maintenance.service";
      };
    };

    systemd.services.mediawiki-maintenance = {
      script = ''
        ${config.services.phpfpm.pools.mediawiki.phpPackage}/bin/php ${config.services.mediawiki.finalPackage}/share/mediawiki/maintenance/run.php runJobs --memory-limit 1G --maxtime 30
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        User = "mediawiki";
        Group = "nginx";
        PrivateTmp = true;
        Environment = "MEDIAWIKI_CONFIG=${config.services.phpfpm.pools.mediawiki.phpEnv.MEDIAWIKI_CONFIG}";
      };
    };

    services.opensearch = {
      # needed for cirrussearch
      enable = true;
      package = project.packages.opensearch.result.${system};
      settings = {
        "http.port" = 1037;
        "path.data" = "/var/lib/private/opensearch/data";
        "path.logs" = "/var/lib/private/opensearch/logs";
      };
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts.${config.ingredient.wiki.wiki.hostname} = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 1036;
        }
      ];

      locations = {
        "= /" = lib.mkForce {
          extraConfig = ''
            return 301 https://${config.ingredient.wiki.wiki.hostname}/wiki/;
          ''; # overriding nixpkgs /wiki/ redirect since as our double-proxy makes it redirect to :1036
        };
        "= /favicon.ico".alias = ./wiki/favicon.ico;
        "= /icon.svg".alias = ./wiki/icon.svg;
      };

      extraConfig = ''
        client_max_body_size 1024M;
      '';
    };
    services.nginx.virtualHosts."external.${config.ingredient.wiki.wiki.hostname}" =
      lib.mkIf config.ingredient.wiki.wiki.enablePublicInternet
        {
          listenAddresses = [
            "0.0.0.0"
            "[::0]"
          ];

          serverName = config.ingredient.wiki.wiki.hostname;

          addSSL = true;
          enableACME = true;
          acmeRoot = null;

          locations."/" = {
            proxyPass = "http://127.0.0.1:1036";
            recommendedProxySettings = true;
            proxyWebsockets = true;

            extraConfig = ''
              proxy_set_header X-Webauth-Login "";
              proxy_cache off;
            '';
          };

          extraConfig = ''
            client_max_body_size 1024M;
          '';
        };
    services.nginx.virtualHosts."internal.${config.ingredient.wiki.wiki.hostname}" = {
      listenAddresses = [ "localhost.tailscale" ];

      serverName = config.ingredient.wiki.wiki.hostname;

      addSSL = true;
      enableACME = true;
      acmeRoot = null;

      locations."/" = {
        proxyPass = "http://127.0.0.1:1036";
        recommendedProxySettings = true;
        proxyWebsockets = true;

        extraConfig = ''
          proxy_cache off;
        '';
      };

      extraConfig = ''
        client_max_body_size 1024M;
      '';
    };

    services.nginx.tailscaleAuth = {
      enable = true;
      virtualHosts = [ "internal.${config.ingredient.wiki.wiki.hostname}" ];
    };
  };
}
