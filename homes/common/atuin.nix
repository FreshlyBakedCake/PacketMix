# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.atuin = {
    enable = true;
    daemon.enable = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      workspaces = true;
      enter_accept = true;

      common_subcommands = [
        "cargo"
        "git"
        "go"
        "ip"
        "jj"
        "nix"
        "nilla"
        "npm"
        "pnpm"
        "sesh"
        "systemctl"
      ];
    };
  };
}
