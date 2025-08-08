# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  lib,
  ...
}:
{
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "eu.nixbuild.net";
        sshKey = "/secrets/remoteBuilds/id_ed25519";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0=";

        system = "x86_64-linux";

        speedFactor = 1; # We have a low speed for nixbuild for x86_64-linux machines: "we have x86_64-linux builders at home" (teal, midnight)
        maxJobs = 100;

        supportedFeatures = [
          "benchmark"
          "big-parallel"
        ];
      }
      {
        hostName = "eu.nixbuild.net";
        sshKey = "/secrets/remoteBuilds/id_ed25519";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0=";

        system = "aarch64-linux";

        maxJobs = 100;

        supportedFeatures = [
          "benchmark"
          "big-parallel"
        ];
      }
      {
        hostName = "eu.nixbuild.net";
        sshKey = "/secrets/remoteBuilds/id_ed25519";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0=";

        system = "armv7l-linux";

        maxJobs = 100;

        supportedFeatures = [
          "benchmark"
          "big-parallel"
        ];
      }
      {
        hostName = "midnight.clicks.domains";
        sshUser = "remoteBuilds";
        sshKey = "/secrets/remoteBuilds/id_ed25519";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU5wbnFKeDlBTGVSS0k0ekVvZnNIL0ZZMFJLaTVsWWtDRVMvR2NWbHNSWncgcm9vdEBhMWQyCg==";

        system = "x86_64-linux";

        speedFactor = 1000;
        maxJobs = 100;

        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }
      {
        hostName = "teal.clicks.domains";
        sshUser = "remoteBuilds";
        sshKey = "/secrets/remoteBuilds/id_ed25519";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBrS2RQU1B4c0xkeDNHVWpqeWliUkxqTGwzWGZhWG1mcnJ2ZW1ERmtqSTMgcm9vdEBhMWQxCg==";

        system = "x86_64-linux";

        speedFactor = 500; # teal isn't necessarily *half as fast*, but we want to build on it less...
        maxJobs = 100;

        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
      }
    ];
  };
}
