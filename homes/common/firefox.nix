# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.firefox.enable = true;

  programs.firefox.configPath = ".mozilla/firefox"; # FIXME: The Firefox default config path changed, but we have state at a specific place already... maybe we should make a systemd oneshot unit to move stuff?
}
