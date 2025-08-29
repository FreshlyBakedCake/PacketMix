# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, ... }:
{
  imports = [ project.inputs.tangled.result.nixosModules.spindle ];

  services.nginx.virtualHosts."spindle.freshlybakedca.ke" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "http://127.0.0.1:1032";
      recommendedProxySettings = true;
    };
  };

  services.tangled-spindle = {
    enable = true;
    server = {
      listenAddr = "127.0.0.1:1032";
      hostname = "spindle.freshlybakedca.ke";
      jetstreamEndpoint = "wss://jetstream1.us-east.bsky.network/subscribe";
      owner = "did:plc:k2zmz2l3hvfr44tmlhewol2j";
    };
    pipelines.stepTimeout = "2h";
  };
}
