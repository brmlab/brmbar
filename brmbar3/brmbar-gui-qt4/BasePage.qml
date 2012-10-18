// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtQuick 1.0

Rectangle {
    width: 1024
    height: 768
    color: "#000000"
    Text {
        id: title
        x: 65
        y: 35
	height: 65
        color: "#217777"
        text: "brmbar v3"
	verticalAlignment: Text.AlignVCenter
        font.pixelSize: 0.768 * 49
    }
    BarClock {
        id: clock
        x: 328
        y: 35
        color: "#000000"
        textColor: "#217777"
        textSize: 0.768 * 49
    }

    Image {
        id: image1
        x: 688
        y: 41
        height: 65
        smooth: true
        fillMode: Image.PreserveAspectFit
        source: "brmlab.svg"
    }

    property alias status_text: status_text_id
    Text {
        id: status_text_id
        x: 65
        y: 112
        width: 894
        color: "#ff4444"
        text: ""
        horizontalAlignment: Text.AlignHCenter
        //anchors.horizontalCenter: clock.horizontalCenter
        font.pixelSize: 0.768 * 49

        state: "HIDDEN"
        opacity: 0

        states: [
            State {
                name: "HIDDEN"
                PropertyChanges { target: status_text; opacity: 0 }
            },
            State {
                name: "VISIBLE"
                PropertyChanges { target: status_text; opacity: 100 }
            }
        ]

        transitions: [
            Transition {
                from: "VISIBLE"
                to: "HIDDEN"
                NumberAnimation { property: "opacity"; duration: 12000; easing.type: Easing.InOutCubic  }
            }
        ]

        function setStatus(statusText, statusColor) {
            text = statusText
            color = statusColor
            state = "VISIBLE"
            state = "HIDDEN"
        }
        function hideStatus() {
            state = "HIDDEN"
        }
    }
}
