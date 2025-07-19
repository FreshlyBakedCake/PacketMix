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

    serverAliases = [ "www.spindle.freshlybakedca.ke" ];

    locations."/" = {
      proxyPass = "http://127.0.0.1:1032";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };

  services.nginx.commonHttpConfig = ''
    error_log stderr debug;
  '';

  services.tangled-spindle = {
    enable = true;
    server = {
      listenAddr = "127.0.0.1:1032";
      hostname = "spindle.freshlybakedca.ke";
      jetstreamEndpoint = "wss://jetstream1.us-east.bsky.network/subscribe";
      owner = "did:plc:k2zmz2l3hvfr44tmlhewol2j";
    };
    pipelines.workflowTimeout = "2h";
  };

  clicks.storage.impermanence.persist.directories = [ "/var/lib/docker" "/var/lib/spindle" ];
}
