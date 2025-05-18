{ pkgs, lib, ...}: {
  fonts.packages = [
    pkgs.cantarell-fonts
    pkgs.carlito
    pkgs.corefonts
    pkgs.fira-code
    pkgs.fira-sans
  ];

  fonts.enableDefaultPackages = true;
}
