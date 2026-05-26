# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, lib, ... }:
{
  services.kanidm = {
    client = {
      enable = true;
      settings.uri = "https://idm.freshly.space";
    };

    package = lib.lowPrio pkgs.kanidm_1_10; # lowPrio because otherwise `orca` ("Orca Load Testing Utility") from kanidm overrides `orca` the screen reader...

  };

}
