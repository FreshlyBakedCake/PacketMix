# SPDX-FileCopyrightText: 2026 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.fish.loginShellInit = ''
    function fish_greeting
      echo Welcome to (set_color yellow)(hostname)(set_color normal) - See (set_color green)go/(prompt_hostname)(set_color normal) for server specification and purpose
    end
  ''; # Show a greeting when logging in specifically - i.e. creating a new ssh session, say
}
