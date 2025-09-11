# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  config,
  options,
  lib,
  ...
}:
{
  imports = [
    project.inputs.walker.result.homeManagerModules.walker
  ];

  config = {
    programs.niri.settings.binds."Mod+D".action.spawn = "${config.programs.walker.package}/bin/walker";

    programs.walker = {
      enable = true;
      runAsService = true;
    };
    programs.elephant.providers =
      let
        allProviders = options.programs.elephant.providers.type.nestedTypes.elemType.functor.payload.values;
        disabledProviders = [
          "files" # disabled because this forces us to index every file in home - which can get ridiculously slow with, e.g., LibreOffice clones
        ];
      in
      builtins.filter (name: !(builtins.elem name disabledProviders)) allProviders;

    systemd.user.services.elephant.Unit.After = [ "niri.service" ];
    systemd.user.services.walker.Unit.After = [ "niri.service" ];
    systemd.user.services.elephant.Unit.WantedBy = lib.mkForce [ "niri.service" ];
    systemd.user.services.walker.Unit.WantedBy = lib.mkForce [ "niri.service" ];
    systemd.user.services.elephant.Unit.PartOf = lib.mkForce [ ];
    systemd.user.services.walker.Unit.PartOf = lib.mkForce [ ];
  };
}
