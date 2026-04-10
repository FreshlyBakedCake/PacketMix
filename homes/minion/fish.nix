# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.fish.enable = true;

  programs.fish.interactiveShellInit = ''
    function fish_greeting
      echo ''
  # This will be auto-wrapped when it's printed by fish - but it's easier to read in the config like this...
  + "Welcome to (set_color yellow)fish(set_color normal) on (set_color purple)packetmix(set_color normal) - "
  + "for help, see (set_color green)go/fishhelp(set_color normal), "
  + "for configuration see (set_color green)go/packetmix(set_color normal), "
  + ''
    for hosted services see (set_color green)go/services(set_color normal)
        end
  '';

  clicks.storage.impermanence.persist.directories = [
    ".config/fish"
    ".local/share/fish"
    ".terminfo"
  ];
}
