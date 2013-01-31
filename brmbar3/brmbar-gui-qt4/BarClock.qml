import QtQuick 1.1

Rectangle {
    id: clock
    width:  320
    height: 65
    property variant now: new Date()
    property string textColor: "#000000"
    property real textSize: 0.768 * 16
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
