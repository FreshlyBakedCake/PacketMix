# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
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
        regex = ''@:co(c\.|companies)'';
        replace = "@companies.thecoded.prof";
      }
      {
        regex = ''sky@a(?P<whitespace>\s)'';
        replace = "sky@a.starrysky.fyi{{whitespace}}";
      }
      {
        trigger = ":co: ";
        replace = "Co-Authored-By: ";
      }
      {
        trigger = ":co:coded";
        replace = "Co-Authored-By: Samuel Shuert <me@thecoded.prof>";
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
