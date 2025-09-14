# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, ... }:
{
  imports = [ project.inputs.tangled.result.nixosModules.spindle ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 1024 ];

  services.tangled-spindle = {
    enable = true;
    server = {
      listenAddr = "0.0.0.0:1024";
      hostname = "spindle.freshlybakedca.ke";
      jetstreamEndpoint = "wss://jetstream1.us-east.bsky.network/subscribe";
      owner = "did:plc:k2zmz2l3hvfr44tmlhewol2j";
    };
    pipelines.workflowTimeout = "2h";
  };
}
