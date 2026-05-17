# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  includes = [ ./ingredients.nix ];

  config.lib.ci = false;
  config.lib.constants.undefined = config.lib.modules.when false { };
}
