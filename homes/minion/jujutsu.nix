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
        "jj config set --repo user.email skyler.grey@collabora.com 2>/dev/null && jj describe --reset-author --no-edit"
      ];
      clicks = [
        "util"
        "exec"
        "--"
        "sh"
        "-c"
        "jj config set --repo user.email minion@clicks.codes 2>/dev/null && jj describe --reset-author --no-edit"
      ];
      personal = [
        "util"
        "exec"
        "--"
        "sh"
        "-c"
        "jj config set --repo user.email sky@a.starrysky.fyi 2>/dev/null && jj describe --reset-author --no-edit"
      ];
      freshly = [
        "util"
        "exec"
        "--"
        "sh"
        "-c"
        "jj config set --repo user.email minion@freshlybakedca.ke 2>/dev/null && jj describe --reset-author --no-edit"
      ];
    };
    git.sign-on-push = true;
    signing = {
      behavior = "drop";
      backend = "ssh";
      key = "~/.ssh/id_ed25519_sk_rk_tiny_yubikey_resident.pub";
    };
    user.name = "Skyler Grey";
  };
}
