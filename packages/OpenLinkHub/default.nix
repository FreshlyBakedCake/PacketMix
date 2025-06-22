# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{openlinkhub,...}: 
openlinkhub.overrideAttrs (prev: {
  postInstall = ''
    mkdir -p $out/var/lib/OpenLinkHub
    cp -r ${prev.src}/{static,web} $out/var/lib/OpenLinkHub
    cp ${prev.src}/config.json $out/var/lib/OpenLinkHub
    mkdir $out/var/lib/OpenLinkHub/database
    cp ${prev.src}/database/rgb.json $out/var/lib/OpenLinkHub/database
    cp -r ${prev.src}/database/keyboard $out/var/lib/OpenLinkHub/database

    cp ${prev.src}/99-openlinkhub.rules $out/lib/udev
  '';
})
