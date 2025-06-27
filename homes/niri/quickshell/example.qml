import Quickshell // for PanelWindow
import QtQuick // for Text
import Quickshell.Services.UPower;

PanelWindow {
  anchors {
    top: true
    left: true
    right: true
  }

  // exclusionMode: ExclusionMode.Ignore;

  implicitHeight: 30

  Text {
    id: batt
    // center the bar in its parent component (the window)
    anchors.centerIn: parent

    Timer {
      interval: 1000
      running: true
      repeat: true
      onTriggered: batt.text = UPower.displayDevice.percentage;
    }
  }
}
