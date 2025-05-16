{ pkgs, ... }: {
  services.udev.packages = [
    pkgs.android-udev-rules
  ];
  users.users.minion.extraGroups = [ "adbusers" ];
}
