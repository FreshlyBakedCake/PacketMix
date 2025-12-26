# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  system,
  config,
  pkgs,
  lib,
  ...
}:
{
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
      CategoryWatch = project.inputs.CategoryWatch.src;
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
      NamespacePreload = project.inputs.NamespacePreload.src;
      OpenIDConnect = "${
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
      PluggableAuth = project.inputs.PluggableAuth.src; # needed for OIDC
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
      $wgGroupPermissions['autoconfirmed']['interwiki'] = true; // https://wiki.freshly.space/wiki/Special:Interwiki - edit shortlink prefixes, crazy-strong permission but we trust our friends
      $wgAllowCopyUploads = true;
      $wgCopyUploadsFromSpecialUpload = true;

      $wgSMTP = [
        'host'      => 'ssl://mail.freshly.space',
        'IDHost'    => 'wiki.freshly.space',
        'localhost' => 'wiki.freshly.space',
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
      $wgGroupPermissions['*']['autocreateaccount'] = true;

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

      $wgShowExceptionDetails = true;
      $wgDevelopmentWarnings = true;
    '';
    webserver = "nginx";
    url = "https://wiki.freshly.space";
    nginx.hostName = "wiki.freshly.space";
    name = "Freshly Wiki";
    database.createLocally = true;

    passwordSender = "wiki@freshly.space";

    passwordFile = "/secrets/mediawiki/initial_admin_password.txt";
  };

  systemd.timers.mediawiki-maintenance = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnUnitActiveSec = "5min";
      OnBootSec = "5min";
      Persistent = false;
      Unit = "mediawiki-maintenance.service";
    };
  };

  systemd.services.mediawiki-maintenance = {
    script = ''
      ${config.services.phpfpm.pools.mediawiki.phpPackage}/bin/php ${config.services.mediawiki.finalPackage}/share/mediawiki/maintenance/run.php runJobs --memory-limit 1G --wait
    '';
    serviceConfig = {
      RemainAfterExit = false;
      Type = "oneshot";
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
  services.headscale.settings.dns.extra_records = [
    {
      # wiki.freshly.space -> teal
      name = "wiki.freshly.space";
      type = "A";
      value = "100.64.0.5";
    }
  ];
  services.nginx.virtualHosts."wiki.freshly.space" = {
    listen = [
      {
        addr = "127.0.0.1";
        port = 1036;
      }
    ];

    locations = {
      "= /" = lib.mkForce {
        extraConfig = ''
          return 301 https://wiki.freshly.space/wiki/;
        ''; # overriding nixpkgs /wiki/ redirect since as our double-proxy makes it redirect to :1036
      };
      "= /favicon.ico".alias = ./wiki/favicon.ico;
      "= /icon.svg".alias = ./wiki/icon.svg;
    };

    extraConfig = ''
      client_max_body_size 1024M;
    '';
  };
  services.nginx.virtualHosts."external.wiki.freshly.space" = {
    listenAddresses = [
      "0.0.0.0"
      "[::0]"
    ];

    serverName = "wiki.freshly.space";

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
  services.nginx.virtualHosts."internal.wiki.freshly.space" = {
    listenAddresses = [ "localhost.tailscale" ];

    serverName = "wiki.freshly.space";

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
    virtualHosts = [ "internal.wiki.freshly.space" ];
  };
}
