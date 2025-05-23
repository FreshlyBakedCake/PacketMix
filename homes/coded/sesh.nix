{ lib, ...}: {
  programs.sesh = {
    enable = true;
    settings = lib.importers.toml ./sesh.toml;
  };
}
