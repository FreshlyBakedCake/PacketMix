# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  xdg.configFile."espanso/match/collabora.yml".text = builtins.toJSON {
    matches = [
      {
        trigger = ":co:work";
        replace = "Co-Authored-By: Skyler Grey <skyler.grey@collabora.com>";
      }
      {
        trigger = ":syst";
        replace = "sudo mount --bind /nix systemplate/nix";
      }
      {
        trigger = ":work";
        replace = "Skyler Grey <skyler.grey@collabora.com>";
      }
      {
        trigger = "SJIC";
        replace = "St John's Innovation Center";
      }
    ];
  };
  xdg.configFile."espanso/match/javascript.yml".text = builtins.toJSON {
    matches = [
      {
        trigger = "//es";
        replace = "// eslint-disable-next-line";
      }
    ];
  };
  xdg.configFile."espanso/match/personal.yml".text = builtins.toJSON {
    matches = [
      {
        regex = ''@(c\.|companies)'';
        replace = "@companies.starrysky.fyi";
      }
      {
        regex = ''sky@a(?P<whitespace>\W)'';
        replace = "sky@a.starrysky.fyi{{whitespace}}";
      }
      {
        trigger = ":co:me";
        replace = "Co-Authored-By: Skyler Grey <sky@a.starrysky.fyi>";
      }
      {
        trigger = ":me";
        replace = "Skyler Grey <sky@a.starrysky.fyi>";
      }
      {
        trigger = "sky@a.";
        replace = "sky@a.starrysky.fyi";
      }
    ];
  };
}
