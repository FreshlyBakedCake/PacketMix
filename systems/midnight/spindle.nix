# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  pkgs,
  lib,
  ...
}:
{
  imports = [ project.inputs.tangled.result.nixosModules.spindle ];

  networking.firewall.allowedTCPPorts = [ 1024 ];

  services.tangled.spindle = {
    enable = true;
    server = {
      listenAddr = "0.0.0.0:1024";
      hostname = "spindle.freshlybakedca.ke";
      jetstreamEndpoint = "wss://jetstream1.us-east.bsky.network/subscribe";
      owner = "did:plc:k2zmz2l3hvfr44tmlhewol2j";
    };
    pipelines.workflowTimeout = "2h";
  };

  virtualisation.docker.autoPrune = {
    enable = true;
    dates = "hourly";
  };
  systemd.services.docker-prune.serviceConfig.ExecStart = lib.mkForce ''
    ${pkgs.docker}/bin/docker network prune -f ;\
    ${pkgs.docker}/bin/docker container prune -f
  '';

  clicks.storage.impermanence.persist.directories = [
    "/var/lib/docker"
    "/var/lib/spindle"
  ];
}
