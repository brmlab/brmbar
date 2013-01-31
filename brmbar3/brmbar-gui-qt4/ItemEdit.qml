import QtQuick 1.1

Item {
    id: page
    anchors.fill: parent

    property string item_name: item_name_pad.enteredText
    property string dbid: ""
    property string info: ""
    property string buy_price: item_buyprice_pad.enteredText
    property string price: item_sellprice_pad.enteredText

    property string barcode: ""
    state: "normal"

    BarcodeInput {
        color: "#00ff00" /* just for debugging */
	focus: page.state == "normal"
	visible: true
        onAccepted: {
	    var acct = shop.barcodeInput(text)
	    barcode = text
	    text = ""
	    if (typeof(acct) != "undefined") {
		status_text.setStatus("Existing barcode: " + acct.name, "#ff4444")
		/* TODO: Allow override. */
		return
	    }
        if (info.dbid === "") {
		status_text.setStatus("Press [Create] first", "#ff4444")
		return
	    }
	    shop.addBarcode(dbid, barcode)
	    status_text.setStatus("Barcode added.", "#ffff7c")
        }
    }

    Item {
	id: name_row
	visible: page.state == "normal" || page.state == "name_edit"
        x: 65
        y: 166
        width: 774
        height: 60

	Text {
	    id: item_name_text
	    x: 0
	    y: 0
	    width: 534
	    height: 60
	    color: "#ffff7c"
	    text: page.item_name
	    wrapMode: Text.WordWrap
	    verticalAlignment: Text.AlignVCenter
	    font.pixelSize: 0.768 * 46
	}

	BarButton {
	    id: item_name_edit
	    x: 534
	    y: 0
	    width: 240
	    height: 60
	    fontSize: 0.768 * 46
	    text: page.state == "name_edit" ? "Assign" : "Edit"
	    onButtonClick: { if (page.state == "name_edit") page.state = "normal"; else page.state = "name_edit"; }
	}
    }

    BarKeyPad {
        id: item_name_pad
        x: 65
        y: 239
        visible: page.state == "name_edit"
        focus: page.state == "name_edit"
	Keys.onReturnPressed: { item_name_edit.buttonClick() }
	Keys.onEscapePressed: { cancel.buttonClick() }
    }

    Item {
	id: buyprice_row
	visible: page.state == "normal" || page.state == "buyprice_edit"
        x: 65
        y: page.state == "buyprice_edit" ? 166 : 239;
        width: 774
        height: 60

	Text {
	    id: item_buyprice_label
	    x: 0
	    y: 0
	    height: 60
	    width: 200
	    color: "#ffffff"
	    text: "Buy price:"
	    verticalAlignment: Text.AlignVCenter
	    font.pixelSize: 0.768 * 46
	}

	Text {
	    id: item_buyprice
	    x: 200
	    y: 0
	    height: 60
	    width: 248
	    color: "#ffff7c"
	    text: page.buy_price
	    horizontalAlignment: Text.AlignRight
	    verticalAlignment: Text.AlignVCenter
	    font.pixelSize: 0.768 * 46
	}

	BarButton {
	    id: item_buyprice_edit
	    x: 534
	    y: 0
	    width: 240
	    height: 60
	    fontSize: 0.768 * 46
	    text: page.state == "buyprice_edit" ? "Assign" : "Edit"
	    onButtonClick: { if (page.state == "buyprice_edit") page.state = "normal"; else page.state = "buyprice_edit"; }
	}
    }

    BarNumPad {
        id: item_buyprice_pad
        x: 65
        y: 239
        visible: page.state == "buyprice_edit"
        focus: page.state == "buyprice_edit"
	Keys.onReturnPressed: { item_buyprice_edit.buttonClick() }
	Keys.onEscapePressed: { cancel.buttonClick() }
    }

    Item {
	id: sellprice_row
	visible: page.state == "normal" || page.state == "sellprice_edit"
        x: 65
        y: page.state == "sellprice_edit" ? 166 : 306;
        width: 774
        height: 60

	Text {
	    id: item_sellprice_label
	    x: 0
	    y: 0
	    height: 60
	    width: 200
	    color: "#ffffff"
	    text: "Sell price:"
	    verticalAlignment: Text.AlignVCenter
	    font.pixelSize: 0.768 * 46
	}

	Text {
	    id: item_sellprice
	    x: 200
	    y: 0
	    height: 60
	    width: 248
	    color: "#ffff7c"
	    text: page.price
	    horizontalAlignment: Text.AlignRight
	    verticalAlignment: Text.AlignVCenter
	    font.pixelSize: 0.768 * 46
	}

	BarButton {
	    id: item_sellprice_edit
	    x: 534
	    y: 0
	    width: 240
	    height: 60
	    fontSize: 0.768 * 46
	    text: page.state == "sellprice_edit" ? "Assign" : "Edit"
	    onButtonClick: { if (page.state == "sellprice_edit") page.state = "normal"; else page.state = "sellprice_edit"; }
	}
    }

    BarNumPad {
        id: item_sellprice_pad
        x: 65
        y: 239
        visible: page.state == "sellprice_edit"
        focus: page.state == "sellprice_edit"
	Keys.onReturnPressed: { item_sellprice_edit.buttonClick() }
	Keys.onEscapePressed: { cancel.buttonClick() }
    }

    Item {
	id: balance_row
	visible: page.state == "normal" || page.state == "balance_edit"
        x: 65
        y: page.state == "balance_edit" ? 166 : 376;
        width: 774
        height: 60

	Text {
	    id: item_balance_label
	    x: 0
	    y: 0
	    height: 60
	    width: 200
	    color: "#ffffff"
	    text: "Quantity:"
	    verticalAlignment: Text.AlignVCenter
	    font.pixelSize: 0.768 * 46
	}

	Text {
	    id: item_balance
	    x: 200
	    y: 0
	    height: 60
	    width: 248
	    color: page.state == "balance_edit" ? "#ffffff" /* read-only value */ : "#ffff7c"
	    text: info.balance
	    horizontalAlignment: Text.AlignRight
	    verticalAlignment: Text.AlignVCenter
	    font.pixelSize: 0.768 * 46
	}

	BarButton {
	    id: item_balance_restock
	    x: 534
	    y: 0
	    width: 240
	    height: 60
	    fontSize: 0.768 * 46
	    text: page.state == "balance_edit" ? "Add qty" : "Restock"
	    onButtonClick: {
		if (page.state == "balance_edit") {
		    var xi = info; xi.balance = parseInt(xi.balance) + parseInt(balance_addqty_edit.enteredText); info = xi;
		    page.state = "normal";
		} else {
		    page.state = "balance_edit";
		    balance_addqty_edit.enteredText = ""
	        }
	    }
	}
    }

    Item {
	id: balance_addqty
	visible: page.state == "balance_edit"
	x: 65
	y: 239

	BarNumPad {
	    id: balance_addqty_edit
	    x: 0
	    y: 0
	    focus: page.state == "balance_edit"
	    Keys.onReturnPressed: { item_balance_restock.buttonClick() }
	    Keys.onEscapePressed: { cancel.buttonClick() }
	}

	Text {
	    id: balance_addqty_label
	    x: 300
	    y: 10
	    height: 60
	    width: 300
	    color: "#ffffff"
	    text: "Add quantity:"
	    verticalAlignment: Text.AlignVCenter
	    font.pixelSize: 0.768 * 46
	}

	Text {
	    id: balance_addqty_amount
	    x: 640
	    y: 0
	    height: 80
	    width: 248
	    color: "#ffff7c"
	    text: balance_addqty_edit.enteredText
	    verticalAlignment: Text.AlignVCenter
	    font.pixelSize: 0.768 * 60
	}

	Text {
	    id: balance_addqty_legend
	    x: 300
	    y: 120
	    height: 320
	    width: 248
	    color: "#71cccc"
	    text: "Please specify the precise amount of newly\nstocked goods, even if the current quantity\nvalue does not match reality (you can let us\nknow about that at brmbar@brmlab.cz)"
	    font.pixelSize: 0.768 * 27
	}
    }

    BarTextHint {
	id: barcode_row
	visible: page.state == "normal"
        x: 65
        y: 476
        hint_goal: "Add barcode:"
        hint_action: "Scan item now"
    }

    BarButton {
        id: save
        x: 65
        y: 582
        width: 360
        text: dbid == "" ? "Create" : "Save"
        onButtonClick: {
            var xi = info;
            xi["name"] = page.item_name;
            xi["buy_price"] = page.buy_price;
            xi["price"] = page.price;
            info = xi

            var res;
            if (dbid == "") {
                res = shop.newItem(info)
                if (!res) {
                   status_text.setStatus("Please fill all values first.", "#ff4444")
                   return
                }
            } else {
                res = shop.saveItem(dbid, info)
            }

            if (res.cost) {
                status_text.setStatus((dbid == "" ? "Stocked!" : "Restocked!") + " Take " + res.cost + " from the money box.", "#ffff7c")
            } else {
                status_text.setStatus(dbid == "" ? "Item created" : "Changes saved", "#ffff7c")
            }

            if (dbid == "") {
                dbid = res.dbid
                xi = info; xi["dbid"] = page.dbid; info = xi
            } else {
                loadPage("StockMgmt")
            }
        }
    }

    BarButton {
        id: cancel
        x: 599
        y: 582
        width: 360
        text: "Cancel"
        onButtonClick: {
            status_text.setStatus("Edit cancelled", "#ff4444")
            loadPage("StockMgmt")
        }
    }

    Component.onCompleted: {
	if (dbid != "") {
	    info = shop.loadAccount(dbid)
	} else {
	    info = { "name": "", "dbid": "", "buy_price": "", "price": "", "balance": 0 };
	}
	item_name_pad.enteredText = info.name
	item_buyprice_pad.enteredText = info.buy_price
	item_sellprice_pad.enteredText = info.price
    }

    states: [
	State {
	    name: "normal"
	},
	State {
	    name: "name_edit"
	},
	State {
	    name: "buyprice_edit"
	},
	State {
	    name: "sellprice_edit"
	},
	State {
	    name: "balance_edit"
	}
    ]
}
