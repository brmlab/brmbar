// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtQuick 1.0

Item {
    id: page
    anchors.fill: parent

    property variant username: ""
    property variant userdbid: ""
    property variant amount: withdraw_pad.enteredText

    Text {
        id: item_name
        x: 422
        y: 156
        width: 537
        height: 80
        color: "#ffffff"
        text: parent.username ? parent.username : "Credit withdrawal"
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 60
    }

    Text {
        id: text3
        x: 611
        y: 256
        height: 160
        width: 348
        color: "#ffff7c"
        text: parent.amount ? "-" + parent.amount : ""
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 122
    }

    BarTextHint {
        x: 65
        y: 430
        hint_goal: (parent.username ? "" : parent.amount ? "Withdraw:" : "Withdraw amount?")
        hint_action: (parent.username ? (parent.amount ? "" : "(or scan barcode now)") : "Scan barcode now")
    }

    BarNumPad {
	id: withdraw_pad
	x: 65
	y: 195
	visible: parent.username != ""
	focus: parent.username != ""
	Keys.onReturnPressed: { withdraw_button.buttonClick() }
	Keys.onEscapePressed: { cancel.buttonClick() }
    }

    BarcodeInput {
        color: "#00ff00" /* just for debugging */
	focus: parent.username == ""
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
            /* if (username && amount) {
                parent.withdrawCredit()
            } */ /* Always ask for confirmation. */
        }
    }

    BarButton {
        id: withdraw_button
        x: 65
        y: 582
        width: 360
        text: "Withdraw"
        fontSize: 60
        visible: parent.amount && parent.userdbid
        onButtonClick: {
            parent.withdrawCredit()
        }
    }

    BarButton {
        id: cancel
        x: 599
        y: 582
        width: 360
        text: "Cancel"
        onButtonClick: {
            status_text.setStatus("Withdrawal cancelled", "#ff4444")
            loadPage("UserMgmt") /* TODO better "back" navigation? */
        }
    }

    function withdrawCredit() {
        var balance = shop.withdrawCredit(amount, userdbid)
        status_text.setStatus("Withdrawn! "+username+"'s credit is "+balance+".", "#ffff7c")
        loadPage("MainPage")
    }
}
