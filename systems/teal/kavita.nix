{ project, system, ... }: {
  services.kavita = {
    enable = true;
    package = project.packages.kavita.result.${system};
    tokenKeyFile = "/secrets/kavita/tokenKeyFile";
    settings = {
      port = 1032;
      IpAddresses = "127.0.0.1";
    };
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."books.freshly.space" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "http://127.0.0.1:1032";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };
}
