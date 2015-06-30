import QtQuick 1.1

Item {
    id: page
    anchors.fill: parent

    BarTextHint {
        x: 65
        y: 234
        hint_goal: "Buy item:"
        hint_action: "Scan barcode now"
    }

    BarcodeInput {
        onAccepted: {
            var acct = shop.barcodeInput(text)
            text = ""
            if (typeof(acct) == "undefined") {
                status_text.setStatus("Unknown barcode", "#ff4444")
                return
            }
            loadPageByAcct(acct)
        }
    }

    BarButton {
        x: 65
        y: 838
        width: 360
        text: "Charge"
        onButtonClick: {
            loadPage("ChargeCredit")
        }
    }

    BarButton {
        id: management
        x: 855
        y: 838
        width: 360
        text: "Management"
        onButtonClick: {
            loadPage("Management")
        }
    }

    BarButton {
        x: 65
        y: 438
        width: 1150
        text: "* Mroze a Termixy najdes v lednici *"
    }



}
