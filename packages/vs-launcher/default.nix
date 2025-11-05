# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
let
  pins = import ../../npins;
in
{ config, ... }:
{
  config.packages.vs-launcher = {
    systems = [ "x86_64-linux" ];

    package =
      let

      in
      { appimageTools, fetchurl }:
      let
        version = pins.vs-launcher.version;
        pname = "vs-launcher";
        src = fetchurl {
          url = "https://github.com/XurxoMF/vs-launcher/releases/download/${version}/vs-launcher-${version}.AppImage";
          sha256 = "sha256-WohOevunsop8cSg1E+GuUJpYHRfj7XtJEC0xH16A4Hg=";
        };
      in
      appimageTools.wrapType2 {
        inherit pname version src;
        extraPkgs = pkgs: [ pkgs.dotnet-runtime ];
      };
  };
}
