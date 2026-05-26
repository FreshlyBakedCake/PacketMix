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
        trigger = "SJIC";
        replace = "St John's Innovation Center";
      }
      {
        trigger = "sg@c";
        replace = "skyler.grey@collabora.com";
      }
    ];
  };
  xdg.configFile."espanso/match/collabora-timesheets.yml".text = builtins.toJSON {
    matches = [
      {
        regex = '':t(?P<name>[^\s-]+)-?meet'';
        replace = "collabora: productivity: r&d-productivity: project-admin: internal-meeting: {{name}}-meeting";
      }
      {
        trigger = ":tadmin";
        replace = "collabora: collabora: internal: admin: cp-admin: ";
      }
      {
        trigger = ":tevent";
        replace = "collabora: collabora: business-development: event-attendance: event-attendee: ";
      }
      {
        trigger = ":tist";
        replace = "collabora: collabora: business-development: event-attendance: event-attendee: IST/41 committee";
      }
      {
        trigger = ":tmail";
        replace = "collabora: collabora: internal: communications: e-mails: read emails";
      }
      {
        trigger = ":tmeet";
        replace = "collabora: productivity: r&d-productivity: project-admin: internal-meeting: ";
      }
      {
        trigger = ":tmentor";
        replace = "collabora: productivity: r&d-productivity: up-stream: mentoring: ";
      }
      {
        trigger = ":tmobile";
        replace = "collabora: productivity: r&d-productivity: product: collabora-online-25-04: mobile release";
      }
      {
        trigger = ":trnd";
        replace = "collabora: productivity: r&d-productivity: product: collabora-online-25-04: ";
      }
      {
        trigger = ":tstat";
        replace = "collabora: collabora: internal: communications: e-mails: status report";
      }
      {
        trigger = ":ttrain";
        replace = "collabora: collabora: internal-training: training: attendance: ";
      }
      {
        trigger = ":tttt";
        replace = "collabora: productivity: r&d-productivity: tea-time-training: tea-time-training: ";
      }
      {
        trigger = ":tah";
        replace = "collabora: productivity: r&d-productivity: project-admin: internal-meeting: all hands meeting";
      }
      {
        trigger = ":tcwm";
        replace = "collabora: productivity: r&d-productivity: project-admin: internal-meeting: cool-weekly-meeting";
      }
      {
        trigger = ":tidoc";
        replace = "collabora: collabora: internal: communications: wiki: documentation writing";
      }
    ];
  };

}
