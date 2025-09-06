# SPDX-FileCopyrightText: 2016 ESRLabs AG
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, lib, ... }:
{
  users.users.git = {
    isSystemUser = true;
    group = "git";
    shell = "${pkgs.josh}/bin/josh-ssh-shell";
  };
  users.groups.git = { };

  systemd.services.josh = {
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.openssh ];

    environment =
      let
        url_config = repo: ''
          [url "https://tangled.sh/@freshlybakedca.ke/${repo}"]
            insteadOf = "https://tangled.sh/@freshlybakedca.ke/${repo}.git"

          [url "ssh://git@tangled.sh/freshlybakedca.ke/${repo}"]
            insteadOf = "ssh://git@tangled.sh/freshlybakedca.ke/${repo}.git"
        '';
        # ^^ Tangled doesn't support cloning from .git URLs, so we have to not have .git at the end of our repos
        # ^^ Additionally, we can only push to Tangled over SSH, not HTTP

        gitconfig = pkgs.writeTextDir "/.gitconfig" (url_config "patisserie");
      in
      {
        HOME = gitconfig;
      };

    serviceConfig = {
      StateDirectory = [
        "josh"
        "josh/local"
      ];
      User = "git";
      Group = "git";
    };

    script =
      "${pkgs.josh}/bin/josh-proxy"
      + " --local /var/lib/josh/local"
      + " --remote https://tangled.sh/@freshlybakedca.ke"
      + " --remote ssh://git@tangled.sh/freshlybakedca.ke"
      + " --port 1032";
  };

  services.nginx.virtualHosts."git.freshlybakedca.ke" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "http://127.0.0.1:1032";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };

    extraConfig = ''
      client_max_body_size 1024M;
    '';
  };

  services.openssh.extraConfig = ''
    Match User git
      # Largely modified from https://github.com/josh-project/josh/blob/edc9143cda1b8b4debc0dfb59ff6e8eab3c620f6/docker/etc/ssh/sshd_config.template
      AllowStreamLocalForwarding no
      AllowTcpForwarding no
      AllowAgentForwarding yes
      PermitTunnel no
      PermitTTY no
      PermitUserRC no
      X11Forwarding no
      AcceptEnv GIT_PROTOCOL
      ClientAliveInterval 360
      ClientAliveCountMax 0
      PasswordAuthentication no
      HostbasedAuthentication no
      KbdInteractiveAuthentication yes
      # ^^ Used instead of PubkeyAuthentication because it's easy enough to modify PAM to Just Let Git Login Over SSHD
      PubkeyAuthentication no
      SetEnv JOSH_SSH_SHELL_ENDPOINT_PORT=1032

    Match All
    PermitUserEnvironment no
    # ^^ Default is no, but explicitly specified as it would be a potential (albeit unlikely) method of escape from josh shell...
  '';

  security.pam.services.sshd.text = lib.mkDefault (
    lib.mkBefore ''
      auth sufficient ${pkgs.linux-pam}/lib/security/pam_succeed_if.so user = git
    ''
  );

  clicks.storage.impermanence.persist.directories = [ "/var/lib/josh" ];
}
