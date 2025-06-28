import QtQuick

Text {
    required property string eventName
    required property string startTime
    required property string endTime

    color: "white"
    text: `${eventName} • ${startTime}-${endTime}`

    padding: 2
}
