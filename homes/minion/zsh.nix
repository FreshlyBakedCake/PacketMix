# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.zsh = {
    enable = true;
    envExtra = builtins.readFile ./zsh/zshenv.z4h;
    initContent = builtins.readFile ./zsh/zshrc.sh;
    antidote = {
      enable = true;
      plugins = [
        "mafredri/zsh-async path:async.zsh"
      ];
    };
  };

  home.file.".p10k.zsh".source = ./zsh/p10k.zsh;

  clicks.storage.impermanence.persist.directories = [
    ".cache/antidote"
    ".cache/zsh4humans"
    ".terminfo"
  ];
}
