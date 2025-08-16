# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  programs.jujutsu.settings = {
    git.sign-on-push = true;
    include = [
      {
        path-regex = "~/Code/FreshlyBaked";
        file = pkgs.writers.writeTOML "config-freshly.toml" {
          user.email = "coded@freshlybakedca.ke";
        };
      }
    ];
    signing = {
      behavior = "drop";
      backend = "ssh";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpBNIHk/kRhQL7Nl3Fd+UBVRoS2bTpbeerA//vwL2D4 coded";
      backends.ssh.allowed-signers = "~/.ssh/allowed_signers";
    };
    user = {
      name = "Samuel Shuert";
      email = "me@thecoded.prof";
    };
  };
}
