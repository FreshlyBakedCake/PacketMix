# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  config.packages.scriptfs = {
    systems = [ "x86_64-linux" ];

    package =
      {
        fuse3,
        lib,
        pkg-config,
        stdenv,
        ...
      }:
      stdenv.mkDerivation {
        pname = "scriptfs";
        version = config.inputs.scriptfs.src.revision;

        src = config.inputs.scriptfs.src;

        buildInputs = [
          fuse3
          fuse3.dev
        ];

        nativeBuildInputs = [
          pkg-config
        ];

        RELEASE = 1;

        installPhase = ''
          mkdir -p $out/bin
          cp scriptfs $out/bin
        '';

        meta = {
          homepage = "https://github.com/eewanco/scriptfs";
          description = "FUSE that replicates a file system but replaces scripts by the result of their execution";
          maintainers = [ lib.maintainers.minion3665 ];
          license = lib.licenses.gpl3Only;
        };
      };
  };
}
