# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  config.packages.collabora-gtimelog = {
    systems = [ "x86_64-linux" ];

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
        libsoup_2_4,
        pango,
      }:
      (gtimelog.overrideAttrs (oldAttrs: {
        src = config.inputs.collabora-gtimelog.src;
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
              libsoup_2_4
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
