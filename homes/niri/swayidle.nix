# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.ingredient.niri.swayidle.timers = {
    lock = lib.mkOption {
      type = lib.types.int;
      description = "How long while idling before locking the device (in seconds)";
      default = 300;
    };
    sleep = lib.mkOption {
      type = lib.types.addCheck lib.types.int (x: x >= config.ingredient.niri.swayidle.timers.lock);
      description = "How long while idling before sleeping the device (in seconds)";
      default = 450;
    };
  };

  config.systemd.user.services.swayidle = {
    Unit.After = [ "niri.service" ];
    Install.WantedBy = [ "niri.service" ];

    Service.ExecStart = builtins.concatStringsSep " " (
      map (arg: "'${arg}'") [
        "${pkgs.swayidle}/bin/swayidle"
        "-w"
        "timeout"
        (toString config.ingredient.niri.swayidle.timers.lock)
        config.ingredient.niri.niri.lockCommand
        "timeout"
        (toString config.ingredient.niri.swayidle.timers.sleep)
        "niri msg action power-off-monitors"
        "resume"
        "niri msg action power-on-monitors" # Not sure if this is really needed - niri normally powers on monitors on a movement action anyway, but maybe this can affect resuming in different ways?
        "before-sleep"
        config.ingredient.niri.niri.lockCommand
      ]
    ); # There's some nastiness here around "what happens if your commands contain single quotes"... at the moment, don't :)
  };
}
