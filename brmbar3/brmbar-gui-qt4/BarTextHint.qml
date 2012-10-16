// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Item {
    id: main_hint
    width: 894
    height: 80

    property variant hint_goal: ""
    property variant hint_action: ""

    Text {
        id: text1
        x: 0
        y: 0
        color: "#ffffff"
        text: parent.hint_goal
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        font.pixelSize: 60
    }

    Text {
        id: text2
        x: 11
        color: "#40ff5d";
        text: parent.hint_action;
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        transformOrigin: Item.Center; smooth: true; font.bold: false; wrapMode: Text.NoWrap; font.pixelSize: 60;horizontalAlignment: Text.AlignHCenter
    }
}
