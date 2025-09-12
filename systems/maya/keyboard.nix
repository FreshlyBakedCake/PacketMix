# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  services.keyd = {
    enable = true;

    keyboards.default = {
      ids = [
        "*"
        "-1234:5678" # Espanso virtual keyboard
      ];
      settings.main.capslock = "overload(control, esc)";
    };
  };
}
