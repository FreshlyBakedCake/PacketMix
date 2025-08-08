# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, lib, ... }:
let
  cfg = config.clicks.storage.impermanence;
in
{
  options.clicks.storage.impermanence = {
    enable = lib.mkEnableOption "Enable impermanent home files, this requires you to be using the NixOS to home connection";

    volumes.persistent_data = lib.mkOption {
      type = lib.types.str;
      description = "Path on persist device to store persistent data on. This should be identical to your path in NixOS";
      default = "data";
    };
    persist = {
      directories = lib.mkOption {
        type = lib.types.listOf (
          lib.types.oneOf [
            lib.types.str
            (lib.types.attrsOf (
              lib.types.oneOf [
                lib.types.str
                (lib.types.attrsOf lib.types.str)
              ]
            ))
          ]
        );
        description = "List of directories to store between boots";
        default = [ ];
      };
      files = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "List of files to store between boots";
        default = [ ];
      };
    };
  };

  config = {
    home = lib.optionalAttrs cfg.enable {
      persistence."/persist/${cfg.volumes.persistent_data}/${config.home.homeDirectory}" = {
        allowOther = true;
        inherit (cfg.persist) directories files;
      };
    };
  };
}
