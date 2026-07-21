# SPDX-FileCopyrightText: 2026 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{ config, ... }:
{
  config.packages.packetmix-nilla-init = {
    systems = [ "x86_64-linux" ];
    package =
      {
        stdenv,
        writeShellScriptBin,
        coreutils,
        ...
      }:
      let
        npins = "${config.packages.packetmix-npins.result.${stdenv.hostPlatform.system}}/bin/npins";
        cp = "${coreutils}/bin/cp";
        chmod = "${coreutils}/bin/chmod";
      in
      writeShellScriptBin "nilla-init" ''
        set -e
        echo "[nilla-init] Setting up npins"
        ${npins} init
        echo "[nilla-init] Adding nilla pin"
        ${npins} add github nilla-nix nilla --pre-releases # pre-releases is needed for now as the latest release is still an "alpha" 
        echo "[nilla-init] Copying over basic nilla.nix"
        ${cp} --backup --no-target-directory ${./nilla.template.nix} ./nilla.nix
        ${chmod} 640 ./nilla.nix
        echo "[nilla-init] Complete!"
      '';
  };
}
