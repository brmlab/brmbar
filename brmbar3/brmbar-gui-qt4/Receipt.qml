// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtQuick 1.0

Item {
    id: page
    anchors.fill: parent

    property variant user
    property variant description: item_name_pad.enteredText
    property variant amount: amount_pad.enteredText

    state: "normal"

    BarcodeInput {
        color: "#00ff00" /* just for debugging */
	focus: page.state == "normal"
        onAccepted: {
	    var acct = shop.barcodeInput(text)
	    text = ""
	    if (typeof(acct) == "undefined" || acct.acctype != "debt") {
		status_text.setStatus("Unknown barcode", "#ff4444")
		return
	    }
	    user = acct
        }
    }

    Item {
	id: description_row
	visible: page.state == "normal" || page.state == "description_edit"
        x: 65
        y: 166
        width: 890
        height: 60

	Text {
	    id: description_input
	    x: 0
	    y: 0
	    width: 640
	    height: 60
	    color: "#ffff7c"
	    text: page.description
	    wrapMode: Text.WordWrap
	    verticalAlignment: Text.AlignVCenter
	    font.pixelSize: 46
	}

	BarButton {
	    id: description_edit
        x: 591
	    y: 0
	    width: 300
	    height: 60
	    fontSize: 46
	    text: page.state == "description_edit" ? "Assign" : "Description"
	    onButtonClick: { if (page.state == "description_edit") page.state = "normal"; else page.state = "description_edit"; }
	}
    }

    BarKeyPad {
        id: item_name_pad
        x: 65
        y: 239
        visible: page.state == "description_edit"
        focus: page.state == "description_edit"
	Keys.onReturnPressed: { description_edit.buttonClick() }
	Keys.onEscapePressed: { cancel.buttonClick() }
    }

    Item {
	id: amount_row
	visible: page.state == "normal" || page.state == "amount_edit"
        x: 65
        y: page.state == "amount_edit" ? 166 : 239;
        width: 890
        height: 60

	Text {
	    id: item_sellprice_label
	    x: 0
	    y: 0
	    height: 60
	    width: 200
	    color: "#ffffff"
	    text: "Money Amount:"
	    verticalAlignment: Text.AlignVCenter
	    font.pixelSize: 46
	}

	Text {
	    id: amount_input
	    x: 320
	    y: 0
	    height: 60
            width: 269
	    color: "#ffff7c"
	    text: amount
	    horizontalAlignment: Text.AlignRight
	    verticalAlignment: Text.AlignVCenter
	    font.pixelSize: 46
	}

	BarButton {
	    id: amount_edit
	    x: 650
	    y: 0
	    width: 240
	    height: 60
	    fontSize: 46
	    text: page.state == "amount_edit" ? "Assign" : "Edit"
	    onButtonClick: { if (page.state == "amount_edit") page.state = "normal"; else page.state = "amount_edit"; }
	}
    }

    BarNumPad {
        id: amount_pad
        x: 65
        y: 239
        visible: page.state == "amount_edit"
        focus: page.state == "amount_edit"
	Keys.onReturnPressed: { amount_edit.buttonClick() }
	Keys.onEscapePressed: { cancel.buttonClick() }
    }

    BarTextHint {
	id: barcode_row
	visible: page.state == "normal"
        x: 65
        y: 314
        hint_goal: "Receipt owner:"
        hint_action: typeof(user) != "undefined" ? user.name : "Scan user now"
    }

    Text {
	id: legend
	visible: page.state == "normal"
	x: 65
	y: 410
	height: 154
	width: 894
	color: "#71cccc"
	text: "This is for cashing in small brmlab expenses.\nWrite the current date on the receipt and put it to the money box.\nDo not forget to announce this on a meetup and add it to the [[newz]].\nFor restocking brmbar items, please go to the Management view instead."
	wrapMode: Text.WordWrap
	horizontalAlignment: Text.AlignHCenter
	font.pixelSize: 27
    }

    BarButton {
        id: save
        x: 65
        y: 582
        width: 360
        text: "Create"
        onButtonClick: {
	    if (typeof(user) == "undefined") {
	       status_text.setStatus("Someone must be responsible for each receipt.", "#ff4444")
	       return
	    }
	    var balance = shop.newReceipt(user.id, description, amount)
	    if (typeof(balance) == "undefined") {
	       status_text.setStatus("Please fill all values first.", "#ff4444")
	       return
	    }

	    status_text.setStatus("Added to "+user.name+"'s credit, now "+balance+".", "#ffff7c")
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
            status_text.setStatus("Receipt cancelled", "#ff4444")
            loadPage("MainPage")
        }
    }

    states: [
	State {
	    name: "normal"
	},
	State {
	    name: "amount_edit"
	},
	State {
	    name: "description_edit"
	}
    ]
}
