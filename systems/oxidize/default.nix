# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ lib, config, ... }:
{
  options.oxidize.unstable = lib.mkEnableOption "Enable unstable/in development rust drop in replacements";
  imports = [
    ./eza.nix
  ] ++ (if config.oxidize.unstable then [ ./uutils.nix ] else [ ]);
}
