// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Rectangle {
    id: rectangle1
    width: 240
    height: 83
    color: "#000000"
    border.color: btnColor

    property string text: "Button"
    property int fontSize: 0.768 * 60
    property variant btnColor: "#ffffff"

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
