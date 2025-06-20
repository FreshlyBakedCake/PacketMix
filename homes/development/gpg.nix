# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{ pkgs, ... }:
{
  programs.gpg = {
    enable = true;
    scdaemonSettings = {
      reader-port = "Yubico Yubi";
      disable-ccid = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };
}
