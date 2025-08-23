# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  pkgs,
  lib,
  system,
  ...
}:
let
  /**
    These users are listed in a specific order: this is the order they will show up in the fava dropdown menu (the first one being the default)
    - The "slug" is user visible - it's the name of the config file which is displayed in the UI in a few places. Changing this will lose the userdata unless it is manually copied
    - The "name" is the name that gets actually shown as the account name in the UI
    - The "beancountOptions" are documented here: <https://beancount.github.io/docs/beancount_options_reference.html>. They get written to a read-only file in the nix store
    - The "favaOptions" are documented here - <https://fava.pythonanywhere.com/huge-example-file/help/options>. They get written alongside the beancount options
    - The "extraConfig" also gets written alongside the beancount options
  */
  users = [
    {
      slug = "freshlybakedcake";
      name = "FreshlyBakedCake";
      beancountOptions.operating_currency = "GBP";
    }
    {
      slug = "minion";
      name = "Skyler Grey";
      beancountOptions.operating_currency = "GBP";
      favaOptions = {
        invert-income-liabilities-equity = "true";
        auto-reload = "true";
        fiscal-year-end = "04-05";
        import-config = builtins.toString ./fava/minion/truelayer.py;
        import-dirs = "/var/lib/private/fava/minion/";
      };
      extraConfig = ''
        plugin "fava.plugins.tag_discovered_documents"
        plugin "fava.plugins.link_documents"

        plugin "beancount.plugins.pedantic"
        plugin "beancount.plugins.unrealized" "Unrealized"
        plugin "beancount.plugins.implicit_prices"

        plugin "beancount_share.share" "{
          'mark_name': 'share',
          'meta_name': 'shared',
          'account_debtors': 'Assets:People',
          'account_creditors': 'Liabilities:People',
          'open_date': None,
          'quantize': '0.01'
        }"
      '';
    }
    {
      slug = "coded";
      name = "Samuel Shuert";
      beancountOptions.operating_currency = "USD";
    }
  ];

  userConfigs =
    (map (
      user:
      lib.recursiveUpdate {
        beancountOptions.title = user.name;
        favaOptions.default-file = "/var/lib/private/fava/${user.slug}.beancount";
      } user
    ))
      users;

  userFiles =
    (map (
      userConfig:
      builtins.toString (
        let
          generateFavaOption =
            name: value:
            if value == null then
              ''1970-01-01 custom "fava-option" "${name}"''
            else
              ''1970-01-01 custom "fava-option" "${name}" "${value}"'';
          favaOptions = lib.pipe userConfig.favaOptions [
            (lib.attrsets.mapAttrsToList generateFavaOption)
            (lib.strings.concatStringsSep "\n")
          ];

          generateBeancountOption = name: value: ''option "${name}" "${value}"'';
          beancountOptions = lib.pipe userConfig.beancountOptions [
            (lib.attrsets.mapAttrsToList generateBeancountOption)
            (lib.strings.concatStringsSep "\n")
          ];
        in
        pkgs.writeText "${userConfig.slug}-config" ''
          ${favaOptions}
          ${beancountOptions}
          ${userConfig.extraConfig or ""}

          include "${userConfig.favaOptions.default-file}"
        ''
      )
    ))
      userConfigs;
in
{
  systemd.services.fava = {
    wants = [ "nginx.service" ];
    after = [ "nginx.service" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      FAVA_HOST = "127.0.0.1";
      FAVA_PORT = "1025";
    };

    serviceConfig = {
      StateDirectory = "fava";
      DynamicUser = true;
      LoadCredential = [
        "truelayer_client_secret:/secrets/fava/truelayer_client_secret"
      ];
    };

    script =
      let
        fava = pkgs.fava.overrideAttrs (prevAttrs: {
          propagatedBuildInputs = prevAttrs.propagatedBuildInputs ++ [
            project.packages.beancount-autobean.result.${system}
            project.packages.beancount-beancount_share.result.${system}
            project.packages.beancount-smart_importer.result.${system}
          ];
        });
      in
      "${fava}/bin/fava ${builtins.concatStringsSep " " userFiles}";

    preStart =
      let
        userConfigToCreationScript = userConfig: ''
          ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "${userConfig.favaOptions.default-file}")"
          ${pkgs.coreutils}/bin/touch -a ${userConfig.favaOptions.default-file}
        '';
      in
      lib.trivial.pipe userConfigs [
        (map userConfigToCreationScript)
        (lib.strings.concatStringsSep "\n")
      ];
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."fava.clicks.codes" = {
    listenAddresses = [ "100.64.0.5" ];

    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    serverAliases = [ "www.fava.clicks.codes" ];

    locations."/" = {
      proxyPass = "http://127.0.0.1:1025";
      recommendedProxySettings = true;
    };
  };

  services.nginx.tailscaleAuth = {
    enable = true;
    virtualHosts = [ "fava.clicks.codes" ];
  };

  clicks.storage.impermanence.persist.directories = [
    {
      directory = "/var/lib/private/fava";
      mode = "0700";
      defaultPerms.mode = "0700";
    }
  ];
}
