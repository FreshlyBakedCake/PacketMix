# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  config.packages.treefmt = {
    systems = [ "x86_64-linux" ];

    package =
      { pkgs }:
      config.inputs.treefmt-nix.result.lib.mkWrapper pkgs {
        projectRootFile = "nilla.nix";
        programs.nixfmt.enable = true;

        settings.formatter.qmlformat = {
          command = "${pkgs.bash}/bin/bash";
          options = [
            "-euc"
            "${pkgs.kdePackages.qtdeclarative}/bin/qmlformat -i $@"
            "--"
          ];
          includes = [ "*.qml" ];
        };
      };
  };

  config.packages.nilla-fmt = {
    systems = [ "x86_64-linux" ];

    package =
      { stdenv, system }:
      stdenv.mkDerivation {
        name = "nilla-fmt";

        src = config.packages.treefmt.result.${system};

        dontBuild = true;

        installPhase = ''
          mkdir -p $out/bin
          cp $src/bin/treefmt $out/bin/nilla-fmt
        '';
      };
  };
}
