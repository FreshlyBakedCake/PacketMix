# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  programs.droidcam.enable = true;
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 card_label="Droidcam Webcam"
  '';
}
