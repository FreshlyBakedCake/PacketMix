# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
# SPDX-FileCopyrightText: 2026 Collabora Productivity Limited
#
# SPDX-License-Identifier: MIT

{
  pkgs,
  config,
  lib,
  ...
}:
{
  systemd.user.services.ssh-agent-add = {
    Unit = {
      Description = "Automatically add ssh keys to the agent";
      After = [ "ssh-agent.service" ];
    };

    Service = {
      Type = "oneshot";
      Environment = "SSH_AUTH_SOCK=/run/user/%U/ssh-agent";
      WorkingDirectory = "%h";
      ExecStart = pkgs.writeShellScript "ssh-agent-add.sh" ''
        SSH_KEYS=$(ls .ssh/id_* | grep -v '.pub$')

        if [ ! -z "$SSH_KEYS" ]; then
          ${pkgs.openssh}/bin/ssh-add $SSH_KEYS
        else
          ${pkgs.coreutils}/bin/echo "Didn't find any ssh keys - please make sure you have some id_* files in ~/.ssh"
        fi
      '';
    };

    Install = {
      WantedBy = [ "ssh-agent.service" ];
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks =
      let
        freshly = {
          identityFile = "~/.ssh/id_ed25519_sk_rk_tiny_yubikey_resident";
        }; # TODO: expand this to work for emden/other security keys

        systems = {
          "eu.nixbuild.net" = {
            hostname = "eu.nixbuild.net";
            extraOptions = {
              WarnWeakCrypto = "no";
            };
          };
          "git.freshlybakedca.ke" = {
            forwardAgent = true;
            hostname = "teal";
            user = "git";
          };
          "tangled.dev.redhead.starrysky.fyi" = {
            hostname = "localhost";
            port = 2222;
            user = "git";
          };
          freshly-midnight = freshly // {
            hostname = "midnight";
          };
          freshly-teal = freshly // {
            hostname = "teal";
          };
        };
      in
      systems
      // {
        midnight = systems.freshly-midnight;
        nixbuild = systems."eu.nixbuild.net";
        teal = systems.freshly-teal;
      };
  };
}
