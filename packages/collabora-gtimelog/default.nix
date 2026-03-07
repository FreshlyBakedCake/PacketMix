# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  config.packages.packetmix-collabora-gtimelog = {
    systems = [ "x86_64-linux" ];

    settings.pkgs = config.inputs.nixos-prev.result;

    package =
      {
        atk,
        gdk-pixbuf,
        glib,
        glib-networking,
        gobject-introspection,
        gtimelog,
        gtk3,
        harfbuzz,
        lib,
        libsecret,
        libsoup_3,
        pango,
      }:
      (gtimelog.overrideAttrs (oldAttrs: {
        src = config.inputs.collabora-gtimelog.src;

        patches = (oldAttrs.patches or [ ]) ++ [
          ./printfdebugging/gtimelog-home.patch
          ./printfdebugging/multilogging/1-multiple-configs.patch
          ./printfdebugging/multilogging/2-task-section-properties.patch
          ./printfdebugging/multilogging/3-submit-sections.patch
          ./printfdebugging/multilogging/4-section-logs.patch
          ./printfdebugging/multilogging/5-submittable-sections.patch
          ./printfdebugging/multilogging/6-multiple-tasklists.patch
          ./printfdebugging/multilogging/7-section-totals.patch
          ./printfdebugging/multilogging/8-section-footer.patch
        ];

        makeWrapperArgs = [
          "--set GIO_MODULE_DIR ${
            lib.makeSearchPathOutput "out" "lib/gio/modules" ([
              glib-networking
            ])
          }"
          "--set GI_TYPELIB_PATH ${
            lib.makeSearchPathOutput "out" "lib/girepository-1.0" [
              atk
              gdk-pixbuf
              glib
              gtk3
              harfbuzz
              libsecret
              libsoup_3
              pango
            ]
          }"
        ];
        postInstall = ''
          install -Dm644 gtimelog.desktop $out/share/applications/gtimelog.desktop
          install -Dm644 src/gtimelog/gtimelog.png $out/share/icons/hicolor/48x48/apps/gtimelog.png
        '';
        buildInputs = oldAttrs.buildInputs ++ [ glib-networking ];
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ gobject-introspection ];
      }));
  };
}
