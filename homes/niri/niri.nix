# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ niri, walker }:
{
  project,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    niri.result.homeModules.niri
    walker.result.homeManagerModules.walker
  ];

  options.niri = {
    wallpaper = lib.mkOption {
      type = lib.types.path;
      description = "Path to the desktop wallpaper you'd like to use";
    };
    lockscreen = lib.mkOption {
      type = lib.types.path;
      description = "Path to the lockscreen background you'd like to use, defaults to a greyscale version of your desktop wallpaper";
      default = pkgs.stdenv.mkDerivation {
        name = "niri-lock-background";

        src = config.niri.wallpaper;
        dontUnpack = true;

        buildPhase = ''
          ${pkgs.imagemagick}/bin/magick $src -colorspace Gray $out
        '';
      };
    };
    overviewBackground = lib.mkOption {
      type = lib.types.path;
      description = "Path to the overview background you'd like to use, defaults to a darkened, blurred version of your desktop wallpaper";
      default = pkgs.stdenv.mkDerivation {
        name = "niri-overview-background";

        src = config.niri.wallpaper;
        dontUnpack = true;

        buildPhase = ''
          ${pkgs.imagemagick}/bin/magick $src -blur 0x16 -fill black -colorize 40% $out
        '';
      };
    };
  };

  config = {
    programs.niri =
      let
        lock = ''${config.programs.niri.package}/bin/niri msg action do-screen-transition && ${pkgs.swaylock}/bin/swaylock -i ${config.niri.lockscreen} -s fill -f'';
      in
      {
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

            xkb = lib.mkIf (config.home.keyboard != null) {
              layout = if config.home.keyboard.layout == null then "" else config.home.keyboard.layout;
              model = if config.home.keyboard.model == null then "" else config.home.keyboard.model;
              options = builtins.concatStringsSep "," config.home.keyboard.options;
              variant = if config.home.keyboard.variant == null then "" else config.home.keyboard.variant;
            };
          };

          input.touchpad.natural-scroll = true;
          input.touchpad.click-method = "clickfinger";

          input.warp-mouse-to-focus.enable = true;
          input.focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "0%";
          };

          input.power-key-handling.enable = false;

          binds =
            let
              inherit (config.lib.niri) actions;

              mod = "Super";
              mod1 = "Alt";

              generateWorkspaceBindings = workspaceNumber: {
                "${mod}+${builtins.toString (lib.mod workspaceNumber 10)}".action.focus-workspace = [
                  workspaceNumber
                ];
                "${mod}+Shift+${builtins.toString (lib.mod workspaceNumber 10)}".action.move-column-to-workspace = [
                  workspaceNumber
                ];
              };
              joinAttrsetList = listOfAttrsets: lib.fold (a: b: a // b) { } listOfAttrsets;
            in
            {
              # General Keybinds
              "${mod}+Q".action.close-window = [ ];
              "${mod}+Shift+Q".action.quit = [ ];
              "${mod}+Return".action.spawn = "${pkgs.ghostty}/bin/ghostty";
              "${mod}+L".action.spawn = [
                "sh"
                "-c"
                lock
              ];
              "${mod}+P".action.power-off-monitors = [ ];

              "${mod}+R".action.screenshot = [ ];
              "${mod}+Ctrl+R".action.screenshot-screen = [ ];
              "${mod}+Shift+R".action.screenshot-window = [ ];
              "Print".action.screenshot = [ ];
              "Ctrl+Print".action.screenshot-screen = [ ];
              "Shift+Print".action.screenshot-window = [ ];

              "${mod}+Space".action.switch-layout = [ "next" ];
              "${mod}+Shift+Space".action.switch-layout = [ "prev" ];

              "${mod}+D".action.spawn = "${config.programs.walker.package}/bin/walker";

              "${mod}+Shift+Slash".action.show-hotkey-overlay = [ ];

              "${mod}+V".action.set-dynamic-cast-monitor = [ ];
              "${mod}+W".action.set-dynamic-cast-window = [ ];
              "${mod}+Shift+V".action.clear-dynamic-cast-target = [ ];
              "${mod}+Shift+W".action.clear-dynamic-cast-target = [ ];

              "${mod}+N".action.spawn = [
                "sh"
                "-c"
                "${pkgs.systemd}/bin/systemctl --user start swaync && ${pkgs.swaynotificationcenter}/bin/swaync-client -t"
              ];
              # We need to ensure swaync is started, since as it isn't usually until we get a notification
            }
            //
              # Workspace Keybinds
              (lib.pipe (lib.range 1 10) [
                (map generateWorkspaceBindings)
                joinAttrsetList
              ])
            //
              # Window Manipulation Bindings
              ({
                "${mod}+BracketLeft".action.consume-or-expel-window-left = [ ];
                "${mod}+BracketRight".action.consume-or-expel-window-right = [ ];
                "${mod}+Shift+BracketLeft".action.consume-window-into-column = [ ];
                "${mod}+Shift+BracketRight".action.expel-window-from-column = [ ];
                "${mod}+Slash".action.switch-preset-column-width = [ ];
                "${mod}+${mod1}+F".action.fullscreen-window = [ ];
                "${mod}+${mod1}+Shift+F".action.toggle-windowed-fullscreen = [ ];

                # Focus
                "${mod}+Up".action.focus-window-or-workspace-up = [ ];
                "${mod}+Down".action.focus-window-or-workspace-down = [ ];

                # Non Jump Movement
                "${mod}+Shift+Up".action.move-window-up-or-to-workspace-up = [ ];
                "${mod}+Shift+Down".action.move-window-down-or-to-workspace-down = [ ];
                "${mod}+Shift+Left".action.consume-or-expel-window-left = [ ];
                "${mod}+Shift+Right".action.consume-or-expel-window-right = [ ];

                # To Monitor
                "${mod}+Shift+Ctrl+Up".action.move-window-to-monitor-up = [ ];
                "${mod}+Shift+Ctrl+Down".action.move-window-to-monitor-down = [ ];
                "${mod}+Shift+Ctrl+Left".action.move-window-to-monitor-left = [ ];
                "${mod}+Shift+Ctrl+Right".action.move-window-to-monitor-right = [ ];

                # To Workspace
                "${mod}+Ctrl+Up".action.move-window-to-workspace-up = [ ];
                "${mod}+Ctrl+Down".action.move-window-to-workspace-down = [ ];

                # Sizing
                "${mod}+Equal".action.set-window-height = [ "+5%" ];
                "${mod}+Minus".action.set-window-height = [ "-5%" ];
              })
            //
              # Column Manipulation Bindings
              ({
                # Focus
                "${mod}+Left".action.focus-column-left = [ ];
                "${mod}+Right".action.focus-column-right = [ ];
                "${mod}+${mod1}+C".action.center-column = [ ];
                "${mod}+F".action.maximize-column = [ ];

                # Non Monitor Movement
                "${mod}+${mod1}+Shift+Up".action.move-column-to-workspace-up = [ ];
                "${mod}+${mod1}+Shift+Down".action.move-column-to-workspace-down = [ ];
                "${mod}+${mod1}+Shift+Left".action.move-column-left = [ ];
                "${mod}+${mod1}+Shift+Right".action.move-column-right = [ ];

                # To Monitor
                "${mod}+${mod1}+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
                "${mod}+${mod1}+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
                "${mod}+${mod1}+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
                "${mod}+${mod1}+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];

                # Sizing
                "${mod}+${mod1}+Equal".action.set-column-width = [ "+5%" ];
                "${mod}+${mod1}+Minus".action.set-column-width = [ "-5%" ];
              })
            //
              # Workspace Manipulation Bindings
              ({
                # Focus
                "${mod}+Page_Up".action.focus-workspace-up = [ ];
                "${mod}+Page_Down".action.focus-workspace-down = [ ];

                # Within Itself
                "${mod}+Shift+Page_Up".action.move-workspace-up = [ ];
                "${mod}+Shift+Page_Down".action.move-workspace-down = [ ];

                # To Monitor
                "${mod}+Shift+Ctrl+Page_Up".action.move-workspace-to-monitor-up = [ ];
                "${mod}+Shift+Ctrl+Page_Down".action.move-workspace-to-monitor-down = [ ];
                "${mod}+Shift+Ctrl+Home".action.move-workspace-to-monitor-left = [ ];
                "${mod}+Shift+Ctrl+End".action.move-workspace-to-monitor-right = [ ];

                "${mod}+Space" = {
                  action.toggle-overview = [ ];
                  repeat = false;
                };
              })
            // {
              # Audio
              "XF86AudioRaiseVolume" = {
                allow-when-locked = true;
                action.spawn = [
                  "${pkgs.wireplumber}/bin/wpctl"
                  "set-volume"
                  "@DEFAULT_AUDIO_SINK@"
                  "0.05+"
                ];
              };
              "XF86AudioLowerVolume" = {
                allow-when-locked = true;
                action.spawn = [
                  "${pkgs.wireplumber}/bin/wpctl"
                  "set-volume"
                  "@DEFAULT_AUDIO_SINK@"
                  "0.05-"
                ];
              };
              "XF86AudioMute" = {
                allow-when-locked = true;
                action.spawn = [
                  "${pkgs.wireplumber}/bin/wpctl"
                  "set-mute"
                  "@DEFAULT_AUDIO_SINK@"
                  "toggle"
                ];
              };
              "XF86AudioMicMute" = {
                allow-when-locked = true;
                action.spawn = [
                  "${pkgs.wireplumber}/bin/wpctl"
                  "set-mute"
                  "@DEFAULT_AUDIO_SOURCE@"
                  "toggle"
                ];
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
              command = [
                "${pkgs.swaybg}/bin/swaybg"
                "-i"
                "${config.niri.wallpaper}"
                "-m"
                "fill"
              ];
            }
            {
              command = [
                "${pkgs.swayidle}/bin/swayidle"
                "-w"
                "timeout"
                "300"
                lock
                "timeout"
                "450"
                "niri msg action power-off-monitors"
                "resume"
                "niri msg action power-on-monitors" # Not sure if this is really needed - niri normally powers on monitors on a movement action anyway, but maybe this can affect resuming in different ways?
                "before-sleep"
                lock
              ];
            }
          ];
        };
      };

    programs.walker.enable = true;

    programs.bash.profileExtra = lib.mkBefore ''
      if [ -z $WAYLAND_DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec ${config.programs.niri.package}/bin/niri-session -l
      fi
    '';

    systemd.user.services.niri = {
      Unit = {
        Description = "A scrollable-tiling Wayland compositor";
        BindsTo = "graphical-session.target";
        Wants = [
          "graphical-session-pre.target"
          "xdg-desktop-autostart.target"
        ];
        After = [
          "graphical-session-pre.target"
          "xdg-desktop-autostart.target"
        ];
      };

      Service = {
        Slice = "session.slice";
        Type = "notify";
        ExecStart = "${config.programs.niri.package}/bin/niri --session";
      };
    };

    systemd.user.services.xdg-desktop-portal = {
      # Overrides the portals from NixOS' `xdg.portal.enable`
      Unit = {
        Description = "Portal service";
        PartOf = "graphical-session.target";
        Requires = "dbus.service";
        After = [
          "dbus.service"
          "niri.service"
        ];
      };

      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.portal.Desktop";
        ExecStart = "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal";
        Slice = "session.slice";
      };
    };
  };
}
