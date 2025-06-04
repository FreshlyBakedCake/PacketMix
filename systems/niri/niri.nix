# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
# SPDX-FileCopyrightText: 2024 sodiboo
#
# SPDX-License-Identifier: MIT
#
# This file is based on some work from sodiboo's niri-flake, see https://github.com/sodiboo/niri-flake/blob/main/flake.nix
{ project, pkgs, lib, ... }: let
  package = pkgs.niri-unstable;
in {
  # we do not use the niri-flake nixos module, as it imports the home-module which causes a duplicate for attached homes

  nixpkgs.overlays = [ project.inputs.niri.result.overlays.niri ];

  nix.settings = {
    substituters = ["https://niri.cachix.org"];
    trusted-public-keys = ["niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="];
  };

  xdg = {
    autostart.enable = lib.mkDefault true;
    menus.enable = lib.mkDefault true;
    mime.enable = lib.mkDefault true;
    icons.enable = lib.mkDefault true;
  };

  services.displayManager.sessionPackages = [ package ];
  hardware.graphics.enable = lib.mkDefault true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    configPackages = [ package ];
  };

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  systemd.user.services.niri-flake-polkit = {
    description = "PolicyKit Authentication Agent provided by niri-flake";
    wantedBy = ["niri.service"];
    after = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  security.pam.services.swaylock = {};
  programs.dconf.enable = lib.mkDefault true;
  fonts.enableDefaultPackages = lib.mkDefault true;

  home-manager.sharedModules = [
    {
      programs.niri.package = lib.mkForce package;
    }
  ];
}
