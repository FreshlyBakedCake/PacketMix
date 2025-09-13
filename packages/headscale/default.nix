# SPDX-FileCopyrightText: 2020 Juan Font
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT and BSD-3-Clause

{ config, ... }:
{
  config.packages.headscale = {
    systems = [ "x86_64-linux" ];
    package =
      {
        lib,
        buildGo124Module,
        ...
      }:
      let
        vendorHash = "sha256-hIY6asY3rOIqf/5P6lFmnNCDWcqNPJaj+tqJuOvGJlo=";
        commitHash = config.inputs.headscale.src.revision;
        headscaleVersion = commitHash;
      in
      buildGo124Module {
        pname = "headscale";
        version = headscaleVersion;
        src = config.inputs.headscale.src;

        # Only run unit tests when testing a build
        checkFlags = [ "-short" ];

        # When updating go.mod or go.sum, a new sha will need to be calculated,
        # update this if you have a mismatch after doing a change to those files.
        inherit vendorHash;

        subPackages = [ "cmd/headscale" ];

        patches = [ ./deferred-auth.patch ];

        ldflags = [
          "-s"
          "-w"
          "-X github.com/juanfont/headscale/hscontrol/types.Version=${headscaleVersion}"
          "-X github.com/juanfont/headscale/hscontrol/types.GitCommitHash=${commitHash}"
        ];

        meta = {
          mainProgram = "headscale";
          maintainer = [ lib.maintainers.minion3665 ];
        };
      };
  };
}
