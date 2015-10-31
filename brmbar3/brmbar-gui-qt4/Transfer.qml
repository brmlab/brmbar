import QtQuick 1.1

Item {
	id: page
	anchors.fill: parent

	property variant userfrom: ""
	property variant uidfrom: ""
	property variant userto: ""
	property variant uidto: ""
	property string amount: amount_pad.enteredText

	BarcodeInput {
		color: "#00ff00" /* just for debugging */
		focus: !(parent.userfrom != "" && parent.userto != "")
		onAccepted: {
			var acct = shop.barcodeInput(text)
			text = ""
			if (typeof(acct) == "undefined") {
				status_text.setStatus("Unknown barcode", "#ff4444")
				return
			}
			if (acct.acctype == "debt") {
				if (userfrom == "") {
					userfrom = acct.name
					uidfrom = acct.id
				} else {
					userto = acct.name
					uidto = acct.id
				}
			} else if (acct.acctype == "recharge") {
				amount = acct.amount
			} else {
				status_text.setStatus("Unknown barcode", "#ff4444")
			}
		}
	}

	Item {
		id: amount_row
		visible: parent.userfrom != "" && parent.userto != ""
		x: 65;
		y: 166;
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
			font.pixelSize: 0.768 * 46
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
			font.pixelSize: 0.768 * 122
		}
	}

	BarNumPad {
		id: amount_pad
		x: 65
		y: 239
		visible: parent.userfrom != "" && parent.userto != ""
		focus: parent.userfrom != "" && parent.userto != ""
		Keys.onReturnPressed: { transfer.buttonClick() }
		Keys.onEscapePressed: { cancel.buttonClick() }
	}

	BarTextHint {
		id: barcode_row
		x: 65
		y: parent.userfrom == "" ? 314 : 414
		hint_goal: (parent.userfrom == "" ? "Take money from:" : parent.userto == "" ? "Give money to:" : parent.amount == "" ? "Specify amount" : "")
		hint_action: (parent.userfrom == "" || parent.userto == "" ? "Scan barcode now" : (parent.amount ? "" : "(or scan barcode now)"))
	}

	Text {
		id: legend
		visible: !(parent.userfrom != "" && parent.userto != "")
		x: 65
		y: 611
		height: 154
		width: 894
		color: "#71cccc"
		text: "This is for transfering credit between two brmbar users.\n May be used instead of *check next club-mate to me*."
		wrapMode: Text.WordWrap
		horizontalAlignment: Text.AlignHCenter
		font.pixelSize: 0.768 * 27
	}

	Text {
	    id: item_name
	    x: 422
	    y: 156
	    width: 537
	    height: 80
	    color: "#ffffff"
	    text: parent.userfrom ? parent.userfrom + " →" : "Money Transfer"
	    wrapMode: Text.WordWrap
	    horizontalAlignment: Text.AlignRight
	    verticalAlignment: Text.AlignVCenter
	    font.pixelSize: 0.768 * 60
	}

	Text {
	    id: item_name2
	    x: 422
	    y: 256
	    width: 537
	    height: 80
	    color: "#ffffff"
	    text: parent.userto ? "→ " + parent.userto : ""
	    wrapMode: Text.WordWrap
	    horizontalAlignment: Text.AlignRight
	    verticalAlignment: Text.AlignVCenter
	    font.pixelSize: 0.768 * 60
	}

	BarButton {
		id: transfer
		x: 65
		y: 838
		width: 360
		text: "Transfer"
		onButtonClick: {
			if (userfrom == "") {
				status_text.setStatus("Select FROM account.", "#ff4444")
				return
			}
			if (userto == "") {
				status_text.setStatus("Select TO account.", "#ff4444")
				return
			}
			if (amount == "") {
				status_text.setStatus("Enter amount.", "#ff4444")
				return
			}
			var amount_str = shop.newTransfer(uidfrom, uidto, amount)
			if (typeof(amount_str) == "undefined") {
				status_text.setStatus("Transfer error.", "#ff4444")
				return
			}

			status_text.setStatus("Transferred " + amount_str + " from " + userfrom + " to " + userto, "#ffff7c")
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
			status_text.setStatus("Transfer cancelled", "#ff4444")
			loadPage("MainPage")
		}
	}
}
