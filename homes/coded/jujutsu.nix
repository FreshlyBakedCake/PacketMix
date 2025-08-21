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
    user = {
      name = "Samuel Shuert";
      email = "me@thecoded.prof";
    };
  };
}
