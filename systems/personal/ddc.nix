{ pkgs, config, ... }: {
  environment.systemPackages = [ pkgs.ddcutil ];
  boot.extraModulePackages = [config.boot.kernelPackages.ddcci-driver];
  boot.kernelModules = ["ddcci_backlight"];
  hardware.i2c.enable = true;
}
