# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ project, ... }:
{
  config.networking.domains.baseDomains."files.freshly.space".cname.data = "a1.clicks.domains";
}
