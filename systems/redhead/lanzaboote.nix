# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  pkgs,
  lib,
  ...
}:
{
  imports = [ project.inputs.lanzaboote.result.nixosModules.lanzaboote ];

  environment.systemPackages = [
    pkgs.sbctl
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    publicKeyFile = "/secrets/lanzaboote/db/db.pem";
    privateKeyFile = "/secrets/lanzaboote/db/db.key";
  };

  environment.etc."sbctl/sbctl.conf".text = builtins.toJSON {
    keydir = "/secrets/lanzaboote";
  };

  clicks.storage.impermanence.persist.directories = [
    "/var/lib/sbctl"
  ];
}
