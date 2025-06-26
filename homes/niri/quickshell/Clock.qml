// SPDX-FileCopyrightText: 2025 FreshlyBakedCake
//
// SPDX-License-Identifier: MIT

import QtQuick

Rectangle {
    id: clock

    property string time: Time.time
    property string date: Time.date
    property bool charging: Battery.valid ? Battery.charging : false

    // These properties may be undefined *or* another type so we currently have to use var for them...
    property var batteryPercentage: Battery.valid ? Battery.percentage : undefined
    property var temperature: undefined
    property var event: undefined

    height: parent.height - 5
    width: childrenRect.width

    color: "transparent"

    x: parent.width / 2 - clock.width / 2
    y: parent.height / 2 - clock.height / 2

    Triline {
        line1: clock.time
        line2: {
            let date = clock.date;
            let battery = "";
            let temperature = "";

            if (Battery.valid) {
                battery = "  " + (clock.charging ? `⚡ ${Math.round(clock.batteryPercentage)}%` : `${Math.round(clock.batteryPercentage)}%`);
            }

            if (clock.temperature !== undefined) {
                temperature = `  ${Math.round(clock.temperature)}`;
            }

            return date + battery + temperature;
        }
        line3: clock.event ? clock.event.text : ""

        width: childrenRect.width
        height: parent.height
    }
}
