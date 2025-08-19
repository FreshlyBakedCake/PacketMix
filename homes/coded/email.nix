# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.aerc.enable = true;

  accounts.email.accounts."gmail" = {
    aerc.enable = true;
    address = "samuel.shuert@gmail.com";
    passwordCommand = "bw get password 'samuel.shuert@gmail.com shorthair app password'";
    imap = {
      host = "imap.gmail.com";
      port = 993;
    };
    smtp = {
      host = "smtp.gmail.com";
      port = 465;
    };
    realName = "Samuel Shuert";
    signature = {
      showSignature = "append";
      text = "Samuel Shuert";
    };
  };

  accounts.email.accounts."personal" = {
    aerc.enable = true;
    primary = true;
    address = "me@thecoded.prof";
    passwordCommand = "bw get notes 'mail.freshly.space App Password'";
    jmap.host = "https://mail.freshly.space";
    jmap.sessionUrl = "https://mail.freshly.space/jmap/session";
    realName = "Samuel Shuert";
    signature = {
      showSignature = "append";
      text = "TheCodedProf | Samuel Shuert";
    };
  };
}
