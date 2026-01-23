# SPDX-FileCopyrightText: 2026 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project }:
{
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "plate" ];
    ensureUsers = [
      {
        name = "plate";
        ensureDBOwnership = true;
      }
    ];
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.plate = {
      autoStart = true;
      ports = [
        "1035:3000"
      ];

      image = "plate-container";
      imageFile = project.inputs.plate.result.packages.container.result."x86_64-linux";

      extraOptions = [
        "--network=host"
        "--mount type=bind,src=/run/postgres,dst=/mnt/postgres"
      ];

      environmentFiles = [
        "/secrets/plate/.env"
      ];
    };
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."plate.thecoded.prof" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "localhost:1035";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };
}
