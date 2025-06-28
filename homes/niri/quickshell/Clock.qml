import QtQuick

Rectangle {
    required property string time;
    required property string date;
    property boolean charging;
    property real batteryPercentage;
    required property real temperature;
    property Event event;

    Text {
        text: time;
    }

    Text {
        text: date;
    }

    Text {
        text: `${Math.round(batteryPercentage * 100)}%`;
    }

    Text {
        text: `${Math.round(temperature)}°`;
    }
    
    event
}
