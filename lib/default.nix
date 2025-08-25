# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  config.lib.ci = false;
  config.lib.constants.undefined = config.lib.modules.when false { };
}
