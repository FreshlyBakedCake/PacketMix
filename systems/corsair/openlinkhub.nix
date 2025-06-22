# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  pkgs,
  config,
  lib,
  system,
  project,
  ...
}:
{
  options.services.openlinkhub.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable OpenLinkHub as a service";
  };

  config =
    let
      pkg = project.packages.openlinkhub.result.${system};
    in
    {
      users.groups.openlinkhub = { };

      users.users.openlinkhub = {
        isSystemUser = true;
        group = config.users.groups.openlinkhub.name;
        extraGroups = [ config.users.groups.input.name ];
      };

      services.udev.packages = [ pkg ];

      systemd.services.openlinkhub =
        let
          path = "/var/lib/OpenLinkHub";
        in
        {
          enable = true;
          description = "Open source interface for iCUE LINK System Hub, Corsair AIOs and Hubs";

          preStart = ''
            mkdir -p ${path}/database
            [ -f ${path}/database/rgb.json ] || cp ${pkg}/var/lib/OpenLinkHub/rgb.json ${path}/database/rgb.json
            [ -f ${path}/database/scheduler.json ] || cp ${pkg}/var/lib/OpenLinkHub/schduler.json ${path}/database/scheduler.json
            mkdir -p ${path}/database/temperatures
            mkdir -p ${path}/database/profiles

            cp -r ${pkg}/var/lib/OpenLinkHub/database/keyboard ${path}/database/keyboard

            [ -L ${path}/static ] || ln -s ${pkg}/var/lib/OpenLinkHub/static ${path}/static
            [ -L ${path}/web ] || ln -s ${pkg}/var/lib/OpenLinkHub/web ${path}/web

            ${pkgs.coreutils}/bin/chmod -R 744 ${path}
            ${pkgs.coreutils}/bin/chown -R openlinkhub:openlinkhub ${path}
          '';

          postStop = ''
            ${pkgs.coreutils}/bin/rm -rf /var/lib/OpenLinkHub/web
            ${pkgs.coreutils}/bin/rm -rf /var/lib/OpenLinkHub/static
          '';

          path = [ pkgs.pciutils ];

          serviceConfig = {
            DynamicUser = true;
            ExecStart = "${pkg}/bin/OpenLinkHub";
            ExecReload = "${pkgs.coreutils}/bin/kill -s HUP \$MAINPID";
            RestartSec = 5;
            PermissionsStartOnly = true;
            StateDirectory = "OpenLinkHub";
            WorkingDirectory = "/var/lib/OpenLinkHub";
          };

          wantedBy = [ "multi-user.target" ];
        };
    };
}
