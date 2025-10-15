# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, lib, ... }:
{
  services.grocy = {
    enable = true;
    package = pkgs.stdenv.mkDerivation {
      name = "grocy-custom-js";
      src = pkgs.grocy;

      dontBuild = true;
      installPhase = ''
        mkdir -p $out/
        cp -r * $out/

        mkdir -p $out/data/
        cp ${./grocy/custom_js.html} $out/data/custom_js.html # we need to specify the filename explicitly, as otherwise this'll have a hash
      '';
    };
    hostName = "grocy.starrysky.fyi";

    settings.currency = "GBP";
  };

  services.nginx.virtualHosts."grocy.starrysky.fyi" = {
    acmeRoot = null;
    forceSSL = lib.mkForce false;
    onlySSL = true;
  };

  clicks.storage.impermanence.persist.directories = [ "/var/lib/grocy" ];
}
