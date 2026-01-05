# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
# SPDX-FileCopyrightText: 2026 Collabora Productivity Limited
#
# SPDX-License-Identifier: MIT

{
  services.headscale.settings.dns.extra_records = [
    {
      # wiki.freshly.space -> teal
      name = "wiki.freshly.space";
      type = "A";
      value = "100.64.0.5";
    }
  ];

  ingredient.wiki.wiki = {
    hostname = "wiki.freshly.space";
    email = "wiki@freshly.space";
    enablePublicInternet = true;
    enableAutoRegistration = true;
  };
}
