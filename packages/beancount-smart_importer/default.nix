# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  config.packages.beancount-smart_importer = {
    systems = [ "x86_64-linux" ];
    package =
      {
        lib,
        python3,
      }:
      let
        pname = "smart_importer";
        version = "0.5";
      in
      python3.pkgs.buildPythonApplication {
        inherit pname version;

        src = config.inputs.beancount-smart_importer.result;

        format = "pyproject";

        propagatedBuildInputs = [
          python3.pkgs.beancount
          python3.pkgs.scikit-learn
          python3.pkgs.numpy
          python3.pkgs.beangulp
        ];

        buildInputs = [
          python3.pkgs.setuptools
          python3.pkgs.setuptools_scm
        ];

        meta = {
          homepage = "https://github.com/beancount/smart_importer";
          description = "Augment Beancount importers with machine learning functionality";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.minion3665 ];
        };
      };
  };
}
