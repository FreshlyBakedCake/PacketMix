# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  services.ollama = {
    enable = true;
    acceleration = "rocm";
  };
  services.nextjs-ollama-llm-ui = {
    enable = true;
    port = 1144;
  };
}
