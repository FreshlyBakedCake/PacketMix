# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.atuin = {
    enable = true; # We're using z4h so we don't have the problems with garbage...
    flags = [ "--disable-up-arrow" ];
    settings = {
      dialect = "uk";
      exit_mode = "return-query";
      inline_height = 0;
      style = "auto";
      update_check = false;
    };
  };

  clicks.storage.impermanence.persist.directories = [
    ".local/share/atuin"
  ];
}
