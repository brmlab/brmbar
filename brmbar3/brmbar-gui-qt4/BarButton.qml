import QtQuick 1.1

Rectangle {
    id: rectangle1
    width: 240
    height: 83
    gradient: Gradient {
        GradientStop {
            position: 0
            color: "#888888"
        }

        GradientStop {
            position: 0.5
            color: "#000000"
        }

        GradientStop {
            position: 1
            color: "#888888"
        }
    }
    border.color: btnColor

    property string text: "Button"
    property int fontSize: 0.768 * 60
    property string btnColor: "#aaaaaa"

    signal buttonClick
    onButtonClick: { /* Supplied by component user. */ }

    Text {
        id: text1
        text: parent.text
        color: parent.btnColor
        font.pixelSize: parent.fontSize
        scale: if (!mousearea1.pressed) { 1 } else { 0.95 }
        horizontalAlignment: Text.AlignHCenter
        anchors.fill: parent
        smooth: true
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        id: mousearea1
        anchors.fill: parent
        onClicked: buttonClick()
    }
}
