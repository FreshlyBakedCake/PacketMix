# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.vdirsyncer.enable = true;
  programs.khal.enable = true;

  accounts.calendar.basePath = ".calendar";

  accounts.calendar.accounts."nextcloud" = {
    primary = true;
    primaryCollection = "Personal";

    khal.enable = true;

    remote = {
      type = "caldav";
      url = "https://nextcloud.clicks.codes/remote.php/dav";
      userName = "clicks-coded";
      passwordCommand = [
        "bw"
        "get"
        "password"
        "'nextcloud calendar app password'"
      ];
    };

    vdirsyncer.enable = true;
  };
}
