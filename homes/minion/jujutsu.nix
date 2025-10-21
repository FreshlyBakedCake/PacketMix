# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.jujutsu.settings = {
    aliases = {
      collabora = [
        "util"
        "exec"
        "--"
        "sh"
        "-c"
        "jj config set --repo user.email skyler.grey@collabora.com 2>/dev/null && jj metaedit --update-author"
      ];
      clicks = [
        "util"
        "exec"
        "--"
        "sh"
        "-c"
        "jj config set --repo user.email minion@clicks.codes 2>/dev/null && jj metaedit --update-author"
      ];
      personal = [
        "util"
        "exec"
        "--"
        "sh"
        "-c"
        "jj config set --repo user.email sky@a.starrysky.fyi 2>/dev/null && jj metaedit --update-author"
      ];
      freshly = [
        "util"
        "exec"
        "--"
        "sh"
        "-c"
        "jj config set --repo user.email minion@freshlybakedca.ke 2>/dev/null && jj metaedit --update-author"
      ];
    };
    git.sign-on-push = true;
    user.name = "Skyler Grey";
  };
}
