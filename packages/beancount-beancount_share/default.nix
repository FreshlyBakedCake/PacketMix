# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  config.packages.beancount-beancount_share = {
    systems = [ "x86_64-linux" ];
    package =
      {
        system,
        lib,
        python3,
      }:
      let
        pname = "beancount_share";
        version = "0.1.10";
      in
      python3.pkgs.buildPythonApplication {
        inherit pname version;

        src = config.inputs.beancount-beancount_share.src;

        format = "pyproject";

        propagatedBuildInputs = [
          python3.pkgs.beancount
          config.packages.beancount-beancount_plugin_utils.result.${system}
        ];

        buildInputs = [
          python3.pkgs.setuptools
          python3.pkgs.pdm-pep517
        ];

        meta = {
          homepage = "https://github.com/Akuukis/beancount_share";
          description = "A beancount plugin to share expenses with external partners within one ledger.";
          license = lib.licenses.agpl3Only;
          maintainers = [ lib.maintainers.minion3665 ];
        };
      };
  };
}
