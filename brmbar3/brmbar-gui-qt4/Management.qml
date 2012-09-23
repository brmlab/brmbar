// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtQuick 1.0

Item {
    id: page
    anchors.fill: parent

    BarButton {
        id: stock_manager
        x: 65
        y: 430
        width: 360
        text: "Stock Mgmt"
    }

    BarButton {
        id: user_manager
        x: 599
        y: 430
        width: 360
        text: "User Mgmt"
    }

    BarButton {
        id: cancel
        x: 599
        y: 582
        width: 360
        text: "Cancel"
        onButtonClick: {
            loadPage("MainPage")
        }
    }
}
