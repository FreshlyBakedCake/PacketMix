{ pkgs, lib, ...}: {
  fonts.packages = [
    pkgs.cantarell-fonts
    pkgs.carlito
    pkgs.corefonts
  ];

  fonts.enableDefaultPackages = true;
}
