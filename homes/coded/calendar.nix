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
      url = "https://nextcloud.clicks.codes/remote.php/dav";
      userName = "clicks-coded";
      passwordCommand = [
        "bw"
        "get"
        "password"
        "nextcloud calendar app password"
      ];
    };

    vdirsyncer.enable = true;
    vdirsyncer.collections = [
      "personal"
      "personal_shared_by_clicks-minion"
      "skyler-ist41_shared_by_clicks-minion"
      "infra_shared_by_clicks-minion"
      "oh-god-what-is-happening_shared_by_clicks-minion"
    ];
  };
}
