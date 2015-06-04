import QtQuick 1.1

Item {
    id: page
    anchors.fill: parent

    property string name: ""
    property string dbid: ""
    property string price: ""

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
        font.pixelSize: 0.768 * 60
    }

    Text {
        id: text3
        x: 867
        y: 156
        height: 160
        width: 348
        color: "#ffff7c"
        text: parent.price
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 0.768 * 122
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
            if (acct.acctype !== "debt" && acct.acctype !== "cash") {
                loadPageByAcct(acct)
                return
            }
            
            if (acct.acctype == "cash") { //Copied from BarButton.onButtonClick
                shop.sellItemCash(dbid)
                status_text.setStatus("Sold! Put " + price + " Kč in the money box.", "#ffff7c")
            } else if (!shop.canSellItem(dbid, acct.id)) {
                status_text.setStatus("NOT SOLD! "+acct.name+"'s credit is TOO LOW: "+shop.balance_user(acct.id), "#ff4444")
            } else {
                var balance = shop.sellItem(dbid, acct.id)
                status_text.setStatus("Sold! "+acct.name+"'s credit is "+balance+".", "#ffff7c")
            }
            loadPage("MainPage")
        }
    }

    BarButton {
        id: pay_cash
        x: 65
        y: 838
        width: 360
        text: "Pay by cash"
        fontSize: 0.768 * 60
        onButtonClick: {
            shop.sellItemCash(dbid)
            status_text.setStatus("Sold! Put " + price + " Kč in the money box.", "#ffff7c")
            loadPage("MainPage")
        }
    }

    BarButton {
        id: cancel
        x: 855
        y: 838
        width: 360
        text: "Cancel"
        onButtonClick: {
            status_text.setStatus("Transaction cancelled", "#ff4444")
            loadPage("MainPage")
        }
    }
}
