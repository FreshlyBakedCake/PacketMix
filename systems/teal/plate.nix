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

      image = "plate";
      imageFile = project.inputs.plate.result.packages.container.result."x86_64-linux";
      volumes = [
        "/run/postgresql:/mnt/postgres"
      ];

      environmentFiles = [
        "/secrets/plate/.env"
      ];
    };
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."plate.today" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "http://localhost:1035";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };
}
