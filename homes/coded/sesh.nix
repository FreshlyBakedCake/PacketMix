# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ lib, ...}: {
  programs.sesh.settings = lib.importTOML ./sesh.toml;
}
