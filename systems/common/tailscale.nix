# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ lib, config, ... }: {
  options.baked.tailscale = {
    enable = lib.mkEnableOption "Enable the tailscale service";
    advertiseExitNode = lib.mkEnableOption "Advertise as an exit node";
    server = lib.mkOption {
      description = "Your control plane server address";
      default = "vpn.clicks.codes";
      example = "controlplane.tailscale.com";
    };
  };

  # Tailscale service config
  config.services.tailscale = lib.mkIf config.baked.tailscale.enable {
    enable = true;
    useRoutingFeatures = if config.baked.tailscale.advertiseExitNode then "both" else "client";
    extraUpFlags = [
      "--login-server=https://${config.baked.tailscale.server}"
      "--accept-routes"
    ] ++ (if config.baked.tailscale.advertiseExitNode then [ "--advertise-exit-node" ] else []);
  };

  # Add directory to impermanence if enabled
  config.clicks.storage.impermanence.perist.directories = lib.mkIf config.clicks.storage.impermanence.enable [ "/var/lib/tailscale" ];

  # Set log support flag depending on control plane address
  config.systemd.services.tailscaled.environment.TS_NO_LOGS_NO_SUPPORT = lib.mkIf ( config.baked.tailscale.server != "controlplane.tailscale.com" ) "true";
}
