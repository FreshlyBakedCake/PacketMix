# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, lib, ... }:
{
  services.kanidm = {
    enableClient = true;

    package = lib.lowPrio pkgs.kanidm_1_9; # lowPrio because otherwise `orca` ("Orca Load Testing Utility") from kanidm overrides `orca` the screen reader...

    clientSettings.uri = "https://idm.freshly.space";
  };

}
