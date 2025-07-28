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
  xdg.configFile."espanso/match/collabora-timesheets.yml".text = builtins.toJSON {
    matches = [
      {
        regex = '':t(?P<name>[^\s-]+)-?meet'';
        replace = "productivity: r&d-productivity: project-admin: internal-meeting: {{name}}-meeting";
      }
      {
        trigger = ":tevent";
        replace = "collabora: business-development: event-attendance: event-attendee: ";
      }
      {
        trigger = ":tmail";
        replace = "collabora: internal: communications: e-mails: read emails";
      }
      {
        trigger = ":tmeet";
        replace = "productivity: r&d-productivity: project-admin: internal-meeting: ";
      }
      {
        trigger = ":tmentor";
        replace = "productivity: r&d-productivity: up-stream: mentoring: ";
      }
      {
        trigger = ":tmobile";
        replace = "productivity: r&d-productivity: product: collabora-online-25-04: mobile release";
      }
      {
        trigger = ":trnd";
        replace = "productivity: r&d-productivity: product: collabora-online-25-04: ";
      }
      {
        trigger = ":tstat";
        replace = "collabora: internal: communications: e-mails: status report";
      }
      {
        trigger = ":ttrain";
        replace = "collabora: internal-training: training: attendance: ";
      }
      {
        trigger = ":tttt";
        replace = "productivity: r&d-productivity: tea-time-training: tea-time-training: ";
      }
      {
        trigger = '':tah'';
        replace = "productivity: r&d-productivity: project-admin: internal-meeting: all hands meeting";
      }
      {
        trigger = '':tcwm'';
        replace = "productivity: r&d-productivity: project-admin: internal-meeting: cool-weekly-meeting";
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
        regex = ''sky@a(?P<whitespace>\s)'';
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
