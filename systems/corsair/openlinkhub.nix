{ pkgs, config, lib, ... }: {
  options.services.openlinkhub = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable OpenLinkHub as a service";
    };
    configFile = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.openlinkhub}/var/lib/OpenLinkHub/config.json";
      description = "OpenLinkHub configuration file";
    };
  };

  config = {
    users.groups.openlinkhub = {};
    
    users.users.openlinkhub = {
      isSystenUser = true;
      group = config.users.groups.openlinkhub;
      extraGroups = [ config.users.groups.input.name ];
    };

    services.udev.packages = [ pkgs.openlinkhub ];

    systemd.services.openlinkhub = let
      path = /var/lib/OpenLinkHub;
    in {
      enable = true;
      description = "Open source interface for iCUE LINK System Hub, Corsair AIOs and Hubs";

      prestart = ''
        mkdir -p ${path}/database
        [ -f ${path}/database/rgb.json ] || cp ${pkgs.openlinkhub}/var/lib/OpenLinkHub/rgb.json ${path}/database/rgb.json
        mkdir -p ${path}/database/temperatures
        mkdir -p ${path}/database/profiles

        cp -r ${pkgs.openlinkhub}/var/lib/OpenLinkHub/database/keyboard ${path}/database/keyboard

        cp ${config.services.openlinkhub.configFile} ${path}/config.json

        [ -L ${path}/static ] || ln -s ${pkgs.openlinkhub}/var/lib/OpenLinkHub/static ${path}/static
        [ -L ${path}/web ] || ln -s ${pkgs.openlinkhub}/var/lib/OpenLinkHub/web ${path}/web

        ${pkgs.coreutils}/bin/chmod -R 744 ${path}
        ${pkgs.coreutils}/bin/chown -R OpenLinkHub:OpenLinkHub ${path}
      '';

      postStop = ''
        ${pkgs.coreutils}/bin/rm -rf /var/lib/OpenLinkHub/web
        ${pkgs.coreutils}/bin/rm -rf /var/lib/OpenLinkHub/static
      '';

      path = [ pkgs.pciutils ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.openlinkhub}/bin/OpenLinkHub";
        ExecReload = "${pkgs.coreutils}/bin/kill -s HUP \$MAINPID";
        RestartSec = 5;
        PermissionsStartOnly = true;
        StateDirectory = "OpenLinkHub";
        WorkingDirectory = "/var/lib/OpenLinkHub";
      };

      watedBy = [ "multi-user.target" ];
    };
  };
}
