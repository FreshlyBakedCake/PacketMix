// SPDX-FileCopyrightText: 2025 FreshlyBakedCake
//
// SPDX-License-Identifier: MIT

import Quickshell

Scope {
    required property string eventName
    required property string startTime
    required property string endTime

    property string text: `${eventName} • ${startTime}-${endTime}`
}
