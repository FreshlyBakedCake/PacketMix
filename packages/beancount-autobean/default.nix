# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  config.packages.beancount-autobean = {
    systems = [ "x86_64-linux" ];
    package =
      {
        lib,
        python3,
      }:
      let
        pname = "autobean";
        version = "0.2.2";
      in
      python3.pkgs.buildPythonApplication {
        inherit pname version;

        src = config.inputs.beancount-autobean.src;

        format = "pyproject";

        propagatedBuildInputs = [
          python3.pkgs.beancount
          python3.pkgs.python-dateutil
          python3.pkgs.pyyaml
          python3.pkgs.requests
        ];

        buildInputs = [
          python3.pkgs.setuptools
          python3.pkgs.pdm-pep517
        ];

        meta = {
          homepage = "https://github.com/SEIAROTg/autobean";
          description = "A collection of plugins and scripts that help automating bookkeeping with beancount";
          license = lib.licenses.gpl2;
          maintainers = [ lib.maintainers.minion3665 ];
        };
      };

  };
}
