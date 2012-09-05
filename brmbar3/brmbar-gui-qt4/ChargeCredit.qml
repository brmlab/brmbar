// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtQuick 1.0

Item {
    id: page
    anchors.fill: parent

    property variant username: ""
    property variant userdbid: ""
    property variant amount: ""

    Text {
        id: item_name
        x: 65
        y: 156
        width: 537
        height: 160
        color: "#ffffff"
        text: parent.username ? parent.username : "Credit charge"
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 44
    }

    Text {
        id: text3
        x: 611
        y: 156
        height: 160
        width: 348
        color: "#ffff7c"
        text: parent.amount
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 90
    }

    BarTextHint {
        x: 65
        y: 430
        hint_goal: parent.amount ? (parent.username ? "Charge now?" : "Charge user:") : "Charge credit:"
        hint_action: !(parent.amount && parent.userdbid) ? "Scan barcode now" : ""
    }

    BarcodeInput {
        color: "#00ff00" /* just for debugging */
        onAccepted: {
            var acct = shop.barcodeInput(text)
            text = ""
            if (typeof(acct) == "undefined" || (parent.username && acct.acctype != "recharge") || (parent.amount && acct.acctype != "debt")) {
                status_text.setStatus("Unknown barcode", "#ff4444")
                return
            }
            if (acct.acctype == "debt") {
                username = acct.name
                userdbid = acct.id
            } else {
                amount = acct.amount
            }
            if (username && amount) {
                parent.chargeCredit()
            }
        }
    }

    BarButton {
        id: charge_button
        x: 65
        y: 582
        width: 360
        text: "Charge"
        fontSize: 44
        visible: parent.amount && parent.userdbid
        onButtonClick: {
            parent.chargeCredit()
        }
    }

    BarButton {
        id: cancel
        x: 599
        y: 582
        width: 360
        text: "Cancel"
        onButtonClick: {
            status_text.setStatus("Charging cancelled", "#ff4444")
            loadPage("MainPage")
        }
    }

    Text {
        id: text1
        x: 112
        y: 333
        width: 800
        height: 80
        color: "#ffffff"
        text: "Put "+amount+" Kč in the money box now."
        visible: amount ? true : false
        anchors.horizontalCenterOffset: 0
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 36
        anchors.horizontalCenter: parent.horizontalCenter
    }

    function chargeCredit() {
        var balance = shop.chargeCredit(amount, userdbid)
        status_text.setStatus("Charged! "+username+"'s credit is "+balance+".", "#ffff7c")
        loadPage("MainPage")
    }
}
