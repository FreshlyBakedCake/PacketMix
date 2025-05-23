# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.aerc.enable = true;
  
  accounts.email.accounts."gmail" = {
    primary = true;
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

  accounts.email.accounts."clicks" = {
    address = "coded@clicks.codes";
    aliases = [
      "me@thecoded.prof"
    ];
    passwordCommand = "bw get notes 'mail.clicks.codes App Password'";
    imap = {
      host = "mail.clicks.codes";
      port = 993;
    };
    smtp = {
      host = "mail.clicks.codes";
      port = 465;
    };
    realName = "Samuel Shuert";
    signature = {
      showSignature = "append";
      text = "TheCodedProf | Samuel Shuert";
    };
  };
}
