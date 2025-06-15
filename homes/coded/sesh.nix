# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.sesh.settings = lib.importers.toml ./sesh.toml;
}
