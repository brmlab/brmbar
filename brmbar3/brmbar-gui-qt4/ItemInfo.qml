// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtQuick 1.0

Item {
    id: page
    anchors.fill: parent

    property variant name: ""
    property variant dbid: ""
    property variant price: ""

    Text {
        id: item_name
        x: 65
        y: 156
        width: 537
        height: 160
        color: "#ffffff"
        text: parent.name
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
        text: parent.price
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 90
    }

    BarTextHint {
        x: 65
        y: 430
        hint_goal: "Buy on credit:"
        hint_action: "Scan barcode now"
    }

    BarcodeInput {
        color: "#00ff00" /* just for debugging */
        onAccepted: {
            var acct = shop.barcodeInput(text)
            text = ""
            if (typeof(acct) == "undefined") {
                status_text.setStatus("Unknown barcode", "#ff4444")
                return
            }
            if (acct.acctype != "debt") {
                loadPageByAcct(acct)
                return
            }
            var balance = shop.sellItem(dbid, acct.id)
            status_text.setStatus("Sold! "+acct.name+"'s credit is "+balance+".", "#ffff7c")
            loadPage("MainPage")
        }
    }

    BarButton {
        id: pay_cash
        x: 65
        y: 582
        width: 360
        text: "Pay by cash"
        fontSize: 44
        onButtonClick: {
            // TODO
            status_text.setStatus("Sold! Put " + price + " Kč in the money box.", "#ffff7c")
            loadPage("MainPage")
        }
    }

    BarButton {
        id: cancel
        x: 599
        y: 582
        width: 360
        text: "Cancel"
        onButtonClick: {
            status_text.setStatus("Transaction cancelled", "#ff4444")
            loadPage("MainPage")
        }
    }
}
