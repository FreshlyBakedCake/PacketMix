# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  config.packages.beancount-beancount_plugin_utils = {
    systems = [ "x86_64-linux" ];
    package =
      {
        lib,
        python3,
      }:
      let
        pname = "beancount_plugin_utils";
        version = "0.0.4";
      in
      python3.pkgs.buildPythonApplication {
        inherit pname version;

        src = config.inputs.beancount-beancount_plugin_utils.src;

        format = "pyproject";

        propagatedBuildInputs = [
          python3.pkgs.beancount
        ];

        buildInputs = [
          python3.pkgs.setuptools
          python3.pkgs.pdm-pep517
        ];

        meta = {
          homepage = "https://github.com/Akuukis/beancount_plugin_utils";
          description = ''
            Utils for beancount plugin writers - BeancountError, mark, metaset, etc.

                    Not ready for public use, but used by various Akuukis plugins.
                    Appears unmaintained'';
          license = lib.licenses.agpl3Only;
          maintainers = [ lib.maintainers.minion3665 ];
        };
      };
  };
}
