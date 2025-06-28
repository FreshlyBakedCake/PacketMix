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

    height: parent.height - 5;
    width: childrenRect.width;
    
    color: "transparent"

    x: parent.width / 2 - clock.width / 2;
    y: parent.height / 2 - clock.height / 2;

    Text {
        id: time

        color: "white"
        text: clock.time

        font.pixelSize: height - topPadding - bottomPadding

        padding: 2
        rightPadding: 7

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Rectangle {
        id: dateline

        color: "transparent"

        width: childrenRect.width

        anchors {
            top: parent.top
            left: time.right
            bottom: parent.verticalCenter
        }

        Text {
            id: date
            color: "white"
            text: clock.date

            padding: 2

            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            visible: clock.batteryPercentage !== undefined

            id: battery
            color: "white"
            text: clock.charging ? `⚡ ${Math.round(clock.batteryPercentage)}%` : `${Math.round(clock.batteryPercentage)}%`

            anchors {
                left: date.right
                top: parent.top
                bottom: parent.bottom

                leftMargin: 7
            }

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            visible: clock.temperature !== undefined

            color: "white"
            text: `${Math.round(clock.temperature)}°`

            anchors {
                left: battery.visible ? battery.right : date.right
                top: parent.top
                bottom: parent.bottom

                leftMargin: 7
            }

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Rectangle {
        visible: clock.event !== undefined

        id: eventline

        color: "transparent"

        width: childrenRect.width

        anchors {
            top: parent.verticalCenter
            left: time.right
            bottom: parent.bottom
        }

        Loader {
            sourceComponent: clock.event
        }
    }
}
