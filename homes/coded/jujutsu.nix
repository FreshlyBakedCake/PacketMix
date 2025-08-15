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
      behavior = "own";
      backend = "gpg";
      key = "me@thecoded.prof";
      backends.gpg.allow-expired-keys = false;
      backends.ssh.allowed-signers = "~/.ssh/allowed_signers";
    };
    user = {
      name = "Samuel Shuert";
      email = "me@thecoded.prof";
    };
  };
}
