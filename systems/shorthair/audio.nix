# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  services.pipewire.extraConfig.pipewire."new-virtual-devices" = {
    "context.modules" = [
      {
        name = "libpipewire-module-combine-stream";
        args = {
          "combine.mode" = "sink";
          "node.name" = "output";
          "node.description" = "Combined Outputs";
          "combine.latency-compensate" = false;
          "combine.props" = {
            "audio.position" = [
              "FL"
              "FR"
            ];
          };
          "stream.props" = {
            "stream.dont-remix" = true;
          };
          "stream.rules" = [
            {
              matches = [
                {
                  "media.class" = "Audio/Sink";
                  "node.name" = "alsa_output.usb-NXP_SEMICONDUCTORS_Razer_Kraken_V3_Pro-00.analog-stereo";
                }
              ];
              actions = {
                create-stream = {
                  "audio.position" = [
                    "FL"
                    "FR"
                  ];
                  "combine.audio.position" = [
                    "FL"
                    "FR"
                  ];
                };
              };
            }
            {
              matches = [
                {
                  "media.class" = "Audio/Sink";
                  "node.name" = "alsa_output.usb-R__DE_RODECaster_Duo_IR0023015-00.pro-output-1";
                }
              ];
              actions = {
                create-stream = {
                  "audio.position" = [
                    "AUX0"
                    "AUX1"
                  ];
                  "combine.audio.position" = [
                    "FL"
                    "FR"
                  ];
                };
              };
            }
          ];
        };
      }
      {
        name = "libpipewire-module-combine-stream";
        args = {
          "combine.mode" = "sink";
          "node.name" = "chat_output";
          "node.description" = "Chat Output";
          "combine.latency-compensate" = false;
          "combine.props" = {
            "audio.position" = [
              "FL"
              "FR"
            ];
          };
          "stream.props" = {
            "stream.dont-remix" = true;
          };
          "stream.rules" = [
            {
              matches = [
                {
                  "media.class" = "Audio/Sink";
                  "node.name" = "alsa_output.usb-R__DE_RODECaster_Duo_IR0023015-00.pro-output-0";
                }
              ];
              actions = {
                create-stream = {
                  "audio.position" = [
                    "AUX0"
                    "AUX1"
                  ];
                  "combine.audio.position" = [
                    "FL"
                    "FR"
                  ];
                };
              };
            }
          ];
        };
      }
      {
        name = "libpipewire-module-combine-stream";
        args = {
          "combine.mode" = "source";
          "node.name" = "input";
          "node.description" = "Input";
          "combine.latency-compensate" = false;
          "combine.props" = {
            "audio.position" = [
              "FL"
              "FR"
            ];
          };
          "stream.props" = {
            "stream.dont-remix" = true;
          };
          "stream.rules" = [
            {
              matches = [
                {
                  "media.class" = "Audio/Source";
                  "node.name" = "alsa_input.usb-R__DE_RODECaster_Duo_IR0023015-00.pro-input-1";
                }
              ];
              actions = {
                create-stream = {
                  "audio.position" = [
                    "AUX0"
                    "AUX1"
                  ];
                  "combine.audio.position" = [
                    "FL"
                    "FR"
                  ];
                };
              };
            }
          ];
        };
      }
    ];
  };
}
