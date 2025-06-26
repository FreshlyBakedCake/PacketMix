// SPDX-FileCopyrightText: 2025 FreshlyBakedCake
//
// SPDX-License-Identifier: MIT

pragma Singleton

import Quickshell
import QtQuick

import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property real percentage: device.percentage * 100
    readonly property bool valid: device.ready && device.isLaptopBattery
    readonly property bool charging: (device.state === UPowerDeviceState.Charging) || (device.state === UPowerDeviceState.FullyCharged)
}
