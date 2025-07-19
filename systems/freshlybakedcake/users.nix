# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{
  users.users.coded = {
    isNormalUser = true;
    description = "Samuel Shuert";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  users.users.minion = {
    isNormalUser = true;
    description = "Skyler Grey";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  users.users.pinea = {
    isNormalUser = true;
    description = "Pinea";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
}
