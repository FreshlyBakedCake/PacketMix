/*
  packetmix.nix: packetmix support configuration, including our binary cache and auto-updating
*/
{ config, pkgs, ... }: {
  nix.settings.substituters = [
    "https://cache.nixos.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];

  system.autoUpgrade = {
    enable = true;
    operation = "boot"; # The default is "switch", but that can lead to some nasty inconsistencies - boot is cleaner
    flags = [
      "-f" "/etc/nixos/nilla.nix"
      "-A" "systems.nixos.${config.networking.hostName}.result"
    ];
  };

  systemd.services.nixos-upgrade.preStart = ''
    cd /etc/nixos
    ${pkgs.git}/bin/git fetch
    ${pkgs.git}/bin/git checkout origin/release
  '';
}
