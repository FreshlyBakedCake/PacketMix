# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.thunderbird
  ];

  clicks.storage.impermanence.persist.directories = [
    ".mozilla/thunderbird"
    ".thunderbird"
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "message/rfc822" = [ "org.mozilla.thunderbird.desktop" ];
      "x-scheme-handler/mailto" = [ "org.mozilla.thunderbird.desktop" ];
    };
  };
}
