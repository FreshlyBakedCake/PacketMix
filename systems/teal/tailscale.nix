# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  systemd.services.tailscaled.environment.TS_NO_LOGS_NO_SUPPORT = "true";

  clicks.storage.impermanence.persist.directories = [ "/var/lib/tailscale" ];
}
