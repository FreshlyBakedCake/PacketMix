// SPDX-FileCopyrightText: 2025 FreshlyBakedCake
//
// SPDX-License-Identifier: MIT

pragma ComponentBehavior: Bound

import Quickshell // for PanelWindow
import QtQuick // for Text
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.Io

/*

Overview has the following gaps...

  fn workspace_gap(&self, zoom: f64) -> f64 {
      let scale = self.scale.fractional_scale();
      let gap = self.view_size.h * 0.1 * zoom;
      round_logical_in_physical_max1(scale, gap)
  }

...zoom by default is 0.5 -> workspaces are 1/2 of the screen size in all dimensions

so by default the gap we have to work with is 1/2 * 1/10 = 1/20th of the screen size
and ranges between 1/4 - 1/20 and 1/4 at the top (=1/5) and 3/4 and 3/4 + 1/20 at the bottom...

...not sure if it's worth calcing this -> guess the cost of having some variables for this isn't really difficult and justifies any Magic Numbers

*/

// we can probably lazyload timers from the 'niri msg event-stream' to stop us doing any background work

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: shell

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            property var modelData
            screen: modelData

            color: "transparent"

            Image {
                id: background
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: "./background.png"
                z: -1
            }

            /* Start properties needed to place this in the overlay */
            WlrLayershell.layer: WlrLayer.Background
            exclusionMode: ExclusionMode.Ignore
            /* End properties needed to place this in the overlay */

            Rectangle {
                id: overviewTopline
                visible: Niri.overview

                QtObject {
                    id: position

                    property int vmin: Math.min(shell.width, shell.height)
                    property int height: vmin * 1 / 20
                    property int toplineAreaBottom: shell.height / 4
                    property int y: toplineAreaBottom - height
                }

                y: position.y

                width: parent.width
                height: position.height

                color: "transparent"

                Clock {}
            }
        }
    }
}
