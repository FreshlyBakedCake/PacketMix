# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ lib, ... }:
{
  services.tailscale.useRoutingFeatures = lib.mkForce "both";
}
