// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Item {
    id: page
    anchors.fill: parent

    property variant name: ""
    property variant dbid: ""
    property variant negbalance: ""

    Text {
        id: item_name
        x: 65
        y: 156
        width: 337
        height: 160
        color: "#ffffff"
        text: parent.name
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        font.fontSize: 0.768 * 60
    }

    Text {
        id: text3
        x: 411
        y: 156
        height: 160
        width: 548
        color: "#ffff7c"
        text: parent.negbalance
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        font.fontSize: 0.768 * 122
    }

    BarcodeInput {
        onAccepted: {
            var acct = shop.barcodeInput(text)
            text = ""
            if (typeof(acct) == "undefined") {
                status_text.setStatus("Unknown barcode", "#ff4444")
                return
            }
            if (acct.acctype == "recharge") {
                loadPage("ChargeCredit", { "username": name, "userdbid": dbid, "amount": acct.amount })
                return
            }

            loadPageByAcct(acct)
        }
    }

    BarButton {
        id: charge_credit
        x: 65
        y: 582
        width: 360
        text: "Charge"
        fontSize: 0.768 * 60
        onButtonClick: {
            loadPage("ChargeCredit", { "username": name, "userdbid": dbid })
        }
    }

    BarButton {
        id: cancel
        x: 599
        y: 582
        width: 360
        text: "Main Screen"
        onButtonClick: {
            loadPage("MainPage")
        }
    }
}
