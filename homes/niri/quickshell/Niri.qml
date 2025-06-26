// SPDX-FileCopyrightText: 2025 FreshlyBakedCake
//
// SPDX-License-Identifier: MIT

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool overview: false

    Process {
        running: true
        command: ["niri", "msg", "event-stream"]
        stdout: SplitParser {
            onRead: data => {
                if (data.startsWith("Overview toggled: ")) {
                    root.overview = data === "Overview toggled: true";
                }
            }
        }
    }
}
