# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ niri, walker }: { project, config, pkgs, lib, ... }: {
  imports = [ niri.result.homeModules.niri walker.result.homeManagerModules.walker ];

  programs.niri = {
    enable = true;

    package = project.inputs.niri.result.packages.${pkgs.system}.niri-unstable;

    settings = {
      environment = {
        NIXOS_OZONE_WL = "1";
        DISPLAY = ":0";
      };

      input.keyboard = {
        track-layout = "window";
        repeat-delay = 200;
        repeat-rate = 25;
        xkb = {
          layout = "us";
          variant = "dvorak";
        };
      };

      input.mouse.natural-scroll = true;
      input.touchpad.natural-scroll = true;

      input.warp-mouse-to-focus = true;
      input.focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "0%";
      };

      input.power-key-handling.enable = false;

      binds = let
        inherit (config.lib.niri) actions;

        mod = "Super";
        mod1 = "Alt";

        lock = ''${pkgs.swaylock}/bin/swaylock -i ${./wallpaper.png} -s fill'';

        generateWorkspaceBindings = workspaceNumber: {
          "${mod}+${builtins.toString (lib.mod workspaceNumber 10)}".action.focus-workspace = [workspaceNumber];
          "${mod}+Shift+${builtins.toString (lib.mod workspaceNumber 10)}".action.move-column-to-workspace = [workspaceNumber];
        };
        joinAttrsetList = listOfAttrsets: lib.fold (a: b: a // b) {} listOfAttrsets;
      in { # General Keybinds
        "${mod}+Q".action.close-window = [];
        "${mod}+Shift+Q".action.quit = [];
        "${mod}+Return".action.spawn = "${pkgs.ghostty}/bin/ghostty";
        "${mod}+L".action.spawn = ["sh" "-c" "${config.programs.niri.package}/bin/niri msg action do-screen-transition && ${lock}"];
        "${mod}+P".action.power-off-monitors = [];

        "${mod}+R".action.screenshot = [];
        "${mod}+Ctrl+R".action.screenshot-screen = [];
        "${mod}+Shift+R".action.screenshot-window = [];
        "Print".action.screenshot = [];
        "Ctrl+Print".action.screenshot-screen = [];
        "Shift+Print".action.screenshot-window = [];

        "${mod}+Space".action.switch-layout = ["next"];
        "${mod}+Shift+Space".action.switch-layout = ["prev"];

        "${mod}+D".action.spawn = "${config.programs.walker.package}/bin/walker";

        "${mod}+Shift+Slash".action.show-hotkey-overlay = [];
      } // ( # Workspace Keybinds
        lib.pipe (lib.range 1 10) [
          (map generateWorkspaceBindings)
          joinAttrsetList
        ]
      ) // ( # Window Manipulation Bindings
      {
        "${mod}+BracketLeft".action.consume-or-expel-window-left = [];
        "${mod}+BracketRight".action.consume-or-expel-window-right = [];
        "${mod}+Shift+BracketLeft".action.consume-window-into-column = [];
        "${mod}+Shift+BracketRight".action.expel-window-from-column = [];
        "${mod}+Slash".action.switch-preset-column-width = [];
        "${mod}+${mod1}+F".action.fullscreen-window = [];

        # Focus
        "${mod}+Up".action.focus-window-or-workspace-up = [];
        "${mod}+Down".action.focus-window-or-workspace-down = [];

        # Non Jump Movement
        "${mod}+Shift+Up".action.move-window-up-or-to-workspace-up = [];
        "${mod}+Shift+Down".action.move-window-down-or-to-workspace-down = [];
        "${mod}+Shift+Left".action.consume-or-expel-window-left = [];
        "${mod}+Shift+Right".action.consume-or-expel-window-right = [];

        # To Monitor
        "${mod}+Shift+Ctrl+Up".action.move-window-to-monitor-up = [];
        "${mod}+Shift+Ctrl+Down".action.move-window-to-monitor-down = [];
        "${mod}+Shift+Ctrl+Left".action.move-window-to-monitor-left = [];
        "${mod}+Shift+Ctrl+Right".action.move-window-to-monitor-right = [];

        # To Workspace
        "${mod}+Ctrl+Up".action.move-window-to-workspace-up = [];
        "${mod}+Ctrl+Down".action.move-window-to-workspace-down = [];

        # Sizing
        "${mod}+Equal".action.set-window-height = ["+5%"];
        "${mod}+Minus".action.set-window-height = ["-5%"];
      }) // ( # Column Manipulation Bindings
      {
        # Focus
        "${mod}+Left".action.focus-column-left = [];
        "${mod}+Right".action.focus-column-right = [];
        "${mod}+${mod1}+C".action.center-column = [];
        "${mod}+F".action.maximize-column = [];

        # Non Monitor Movement
        "${mod}+${mod1}+Shift+Up".action.move-column-to-workspace-up = [];
        "${mod}+${mod1}+Shift+Down".action.move-column-to-workspace-down = [];
        "${mod}+${mod1}+Shift+Left".action.move-column-left = [];
        "${mod}+${mod1}+Shift+Right".action.move-column-right = [];

        # To Monitor
        "${mod}+${mod1}+Shift+Ctrl+Up".action.move-column-to-monitor-up = [];
        "${mod}+${mod1}+Shift+Ctrl+Down".action.move-column-to-monitor-down = [];
        "${mod}+${mod1}+Shift+Ctrl+Left".action.move-column-to-monitor-left = [];
        "${mod}+${mod1}+Shift+Ctrl+Right".action.move-column-to-monitor-right = [];

        # Sizing
        "${mod}+${mod1}+Equal".action.set-column-width = ["+5%"];
        "${mod}+${mod1}+Minus".action.set-column-width = ["-5%"];
      }) // ( # Workspace Manipulation Bindings
      {
        # Focus
        "${mod}+Page_Up".action.focus-workspace-up = [];
        "${mod}+Page_Down".action.focus-workspace-down = [];

        # Within Itself
        "${mod}+Shift+Page_Up".action.move-workspace-up = [];
        "${mod}+Shift+Page_Down".action.move-workspace-down = [];

        # To Monitor
        "${mod}+Shift+Ctrl+Page_Up".action.move-workspace-to-monitor-up = [];
        "${mod}+Shift+Ctrl+Page_Down".action.move-workspace-to-monitor-down = [];
        "${mod}+Shift+Ctrl+Home".action.move-workspace-to-monitor-left = [];
        "${mod}+Shift+Ctrl+End".action.move-workspace-to-monitor-right = [];

        "${mod}+Space".action.toggle-overview = [];
      }) // { # Audio
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn = ["${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05+"];
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn = ["${pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05-"];
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action.spawn = ["${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action.spawn = ["${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];
        };
      };

      outputs = {
        "eDP-1" = { # frame.work laptop internal monitor
          position = {
            x = 0;
            y = 0;
          };
        };
        "Hewlett Packard LA2405 CN40370NRF" = { # work right monitor
          position = {
            x = 1504;
            y = -1200;
          };
          transform.rotation = 90;
        };
        "Hewlett Packard LA2405 CN40500PYR" = { # work left monitor
          position = {
            x = -416;
            y = -1200;
          };
        };
        "Dell Inc. DELL P2715Q V7WP95AV914L" = { # emden mid-monitor
          position = {
            x = 0;
            y = 0;
          };
          scale = 1.5;
        };
        "PNP(AOC) 2460G5 0x00014634" = { # emden left monitor
          position = {
            x = -1080;
            y = -120;
          };
          transform.rotation = 270;
        };
        "PNP(AOC) 2460G5 0x00023C3F" = { # emden right monitor
          position = {
            x = 2560;
            y = 180;
          };
        };
      };

      layout = {
        gaps = 16;

        center-focused-column = "on-overflow";

        preset-column-widths = [
          { proportion = 1. / 4.; }
          { proportion = 1. / 3.; }
          { proportion = 1. / 2.; }
          { proportion = 2. / 3.; }
          { proportion = 9. / 10.; }
        ]; # TODO: clicks to PR a docs update for niri-flake
      };

      prefer-no-csd = true; # No "client-side-decorations" (i.e. client-side window open/close buttons)
      hotkey-overlay.skip-at-startup = true;
      screenshot-path = null;

      spawn-at-startup = [
        {
          command = [ "${pkgs.xwayland-satellite}/bin/xwayland-satellite" ];
        }
        {
          command = [ "${pkgs.swaybg}/bin/swaybg" "-i" "${./wallpaper.png}" "-m" "fill" ];
        }
      ];
    };
  };

  programs.walker.enable = true;

  programs.bash.profileExtra = lib.mkBefore ''
    if [ -z $WAYLAND_DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec ${pkgs.systemd}/bin/systemd-cat -t niri ${pkgs.dbus}/bin/dbus-run-session ${config.programs.niri.package}/bin/niri --session
    fi
  '';
}
