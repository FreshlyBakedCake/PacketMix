# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  systemd.services.nixos-upgrade.onSuccess = [ "nixos-upgrade-restart.service" ];
  systemd.services.nixos-upgrade-restart = {
    description = "Restart the server after a successful nixos-upgrade";

    serviceConfig.oneshot = true;

    script = ''
      booted="$(${pkgs.coreutils}/bin/readlink -f /run/booted-system)"
      latest="$(${pkgs.coreutils}/bin/readlink -f /nix/var/nix/profiles/system)"

      if [ "''${booted}" != "''${latest}" ]; then
        shutdown -r +5
      fi
    '';
  };
}
