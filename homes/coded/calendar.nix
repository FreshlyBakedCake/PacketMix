# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.vdirsyncer.enable = true;
  programs.khal.enable = true;

  accounts.calendar.basePath = ".calendar";

  accounts.calendar.accounts."nextcloud" = {
    primary = true;
    primaryCollection = "personal";

    khal.enable = true;
    khal.type = "discover";

    remote = {
      type = "caldav";
      url = "https://mail.freshly.space/dav/pal/me@thecoded.prof/";
      userName = "me@thecoded.prof";
      passwordCommand = [
        "bw"
        "get"
        "password"
        "mail.freshly.space"
      ];
    };

    vdirsyncer.enable = true;
    vdirsyncer.collections = [
      "personal"
      "default"
    ];
  };
}
