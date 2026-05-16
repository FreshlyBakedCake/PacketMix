# SPDX-FileCopyrightText: 2026 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, config, lib, ... }:
{
  services.automatic-timezoned.enable = lib.mkDefault true;
  boot.postBootCommands = lib.mkIf config.services.automatic-timezoned.enable ''
    ${pkgs.coreutils}/bin/cp --no-dereference /persist/${config.clicks.storage.impermanence.volumes.persistent_data}/etc/localtime /etc/localtime || ${pkgs.coreutils}/bin/true
  '';
  systemd.services.persist-timezone = lib.mkIf config.services.automatic-timezoned.enable {
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = [
        "${pkgs.coreutils}/bin/mkdir -p /persist/${config.clicks.storage.impermanence.volumes.persistent_data}/etc"
        "${pkgs.coreutils}/bin/cp --no-dereference /etc/localtime /persist/${config.clicks.storage.impermanence.volumes.persistent_data}/etc/localtime"
      ];
    };
  }; # The timezone file needs to be a symlink to the zone info - so we can't persist it with our normal impermanence machinery - see https://github.com/nix-community/impermanence/issues/153
}
