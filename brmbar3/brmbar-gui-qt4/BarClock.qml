// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Rectangle {
    id: clock
    width:  320
    height: 65
    property variant now: new Date()
    property variant textColor: "#000000"
    property variant textSize: 0.768 * 16
    Timer {
        id: clockUpdater
        interval: 1000 // update clock every second
        running: true
        repeat: true
        onTriggered: {
            parent.now = new Date()
        }
    }
    Text {
        id: clockLabel
        anchors.centerIn: parent
        text: Qt.formatDateTime(parent.now, "hh:mm:ss")
        color: parent.textColor
        font.pixelSize: parent.textSize
    }
}
