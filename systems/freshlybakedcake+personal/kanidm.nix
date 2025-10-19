# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  services.kanidm = {
    enableClient = true;

    package = pkgs.kanidm_1_7;

    clientSettings.uri = "https://idm.freshly.space";
  };
}
