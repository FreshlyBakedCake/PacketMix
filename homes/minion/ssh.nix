# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
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
}
