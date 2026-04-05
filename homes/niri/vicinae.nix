# SPDX-FileCopyrightText: 2026 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  config,
  project,
  pkgs,
  lib,
  ...
}:
{
  home.packages = [ pkgs.playerctl ];
  programs.niri.settings.binds."Mod+D".action.spawn = [
    "${config.programs.vicinae.package}/bin/vicinae"
    "toggle"
  ];
  programs.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
    };

    settings = {
      closeOnFocusLoss = true;
      considerPreedit = true;
      faviconService = "twenty";

      theme = lib.mkIf config.catppuccin.enable {
        name = "catppuccin-${config.catppuccin.flavor}";
      };
    };

    extensions = [
      # Short to install list: github, xkcd, systemd, bitwarden
      # Vicinae Extensions
      (config.lib.vicinae.mkExtension {
        name = "nix";
        src = "${project.inputs.vicinaeExtensions.src}/extensions/nix";
      })
      (config.lib.vicinae.mkExtension {
        name = "wifi-commander";
        src = "${project.inputs.vicinaeExtensions.src}/extensions/wifi-commander";
      })
      (config.lib.vicinae.mkExtension {
        name = "bluetooth";
        src = "${project.inputs.vicinaeExtensions.src}/extensions/bluetooth";
      })
      (config.lib.vicinae.mkExtension {
        name = "player-pilot";
        src = "${project.inputs.vicinaeExtensions.src}/extensions/player-pilot";
      })
      (config.lib.vicinae.mkExtension {
        name = "brotab";
        src = "${project.inputs.vicinaeExtensions.src}/extensions/brotab";
      })
      (config.lib.vicinae.mkExtension {
        name = "niri";
        src = "${project.inputs.vicinaeExtensions.src}/extensions/niri";
      })
      (config.lib.vicinae.mkExtension {
        name = "it-tools";
        src = "${project.inputs.vicinaeExtensions.src}/extensions/it-tools";
      })
    ];
  };

  systemd.user.services.vicinae.Unit.After = [ "niri.service" ];
  systemd.user.services.vicinae.Install.WandedBy = lib.mkForce [ "niri.service" ];
  systemd.user.services.vicinae.Unit.PartOf = lib.mkForce [ ];

  clicks.storage.impermanence.persist.directories = [
    ".local/share/vicinae"
  ];
}
