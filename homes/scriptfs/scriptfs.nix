# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  pkgs,
  system,
  ...
}:
{
  systemd.user.services.scriptfs = {
    Install.WantedBy = [ "default.target" ];

    Service = {
      ExecStartPre = [
        "-${pkgs.coreutils}/bin/ln -fns %t %S/run" # Useful for some dependents (jujutsu) which cannot expand %t themselves, but prefixed with - to stop a failure bringing down scriptfs
        "${pkgs.coreutils}/bin/mkdir -p %t/scriptfs"
      ];
      ExecStart = "${project.packages.scriptfs.result.${system}}/bin/scriptfs -f /nix/store %t/scriptfs";
    };
  };
}
