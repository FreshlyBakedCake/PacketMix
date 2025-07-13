# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ lib, ... }:
{
  programs.zed-editor = {
    userSettings = {
      helix_mode = lib.mkForce false;
      edit_predictions.mode = lib.mkForce "eager";
      assistant = {
        enabled = true;
        default_model = {
          provider = "copilot_chat";
          model = "gpt-4o";
        };
        inline_alternatives = [
          {
            provider = "copilot_chat";
            model = "gpt-3.5-turbo";
          }
        ];
      };
    };
  };
}
