// SPDX-FileCopyrightText: 2025 FreshlyBakedCake
//
// SPDX-License-Identifier: MIT

import QtQuick

Rectangle {
    id: triline

    property string line1
    property string line2
    property string line3

    property int sizeDecrease: line1metrics.tightBoundingRect.height / 16 // The decrease in font size (pixels) that lines 2 and 3 have - since as without this they will end up looking cramped

    color: "transparent"

    TextMetrics {
        id: line1metrics

        font.pixelSize: line1.height

        text: triline.line1
    }

    Text {
        id: line1

        color: "white"
        font.pixelSize: height

        text: triline.line1

        verticalAlignment: Text.AlignVCenter

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
    }

    Text {
        id: line2

        color: "white"
        font.pixelSize: line1metrics.tightBoundingRect.height / 2 - triline.sizeDecrease

        text: triline.line2
        leftPadding: line1metrics.tightBoundingRect.height / 8

        anchors {
            left: line1.right

            top: line1.baseline
            topMargin: -line1metrics.tightBoundingRect.height

            bottom: line1.baseline
            bottomMargin: -(line1metrics.tightBoundingRect.height / 2)
        }
    }

    Text {
        id: line3

        color: "white"
        font.pixelSize: line1metrics.tightBoundingRect.height / 2 - triline.sizeDecrease

        text: triline.line3
        leftPadding: line1metrics.tightBoundingRect.height / 8

        anchors {
            left: line1.right

            top: line1.baseline
            topMargin: -(line1metrics.tightBoundingRect.height / 2) + triline.sizeDecrease

            bottom: line1.baseline
        }
    }
}
