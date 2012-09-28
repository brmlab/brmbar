// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtQuick 1.0

Item {
    id: page
    anchors.fill: parent

    property variant name: ""
    property variant dbid: ""
    property variant info: ""

    property string barcode: ""
    state: "normal"

    BarcodeInput {
        color: "#00ff00" /* just for debugging */
        onAccepted: {
	    var acct = shop.barcodeInput(text)
	    barcode = text
	    text = ""
	    if (typeof(acct) != "undefined") {
		status_text.setStatus("Existing barcode: " + acct.name, "#ff4444")
		/* TODO: Allow override. */
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
	    id: item_name
	    x: 0
	    y: 0
	    width: 534
	    height: 60
	    color: "#ffff7c"
	    text: page.name
	    wrapMode: Text.WordWrap
	    verticalAlignment: Text.AlignVCenter
	    font.pointSize: 34
	}

	BarButton {
	    id: item_name_edit
	    x: 534
	    y: 0
	    width: 240
	    height: 60
	    fontSize: 34
	    text: page.state == "name_edit" ? "Assign" : "Edit"
	    onButtonClick: { if (page.state == "name_edit") page.state = "normal"; else page.state = "name_edit"; }
	}
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
	    font.pointSize: 34
	}

	Text {
	    id: item_buyprice
	    x: 200
	    y: 0
	    height: 60
	    width: 248
	    color: "#ffff7c"
	    text: info.buy_price
	    horizontalAlignment: Text.AlignRight
	    verticalAlignment: Text.AlignVCenter
	    font.pointSize: 34
	}

	BarButton {
	    id: item_buyprice_edit
	    x: 534
	    y: 0
	    width: 240
	    height: 60
	    fontSize: 34
	    text: page.state == "buyprice_edit" ? "Assign" : "Edit"
	    onButtonClick: { if (page.state == "buyprice_edit") page.state = "normal"; else page.state = "buyprice_edit"; }
	}
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
	    font.pointSize: 34
	}

	Text {
	    id: item_sellprice
	    x: 200
	    y: 0
	    height: 60
	    width: 248
	    color: "#ffff7c"
	    text: info.price
	    horizontalAlignment: Text.AlignRight
	    verticalAlignment: Text.AlignVCenter
	    font.pointSize: 34
	}

	BarButton {
	    id: item_sellprice_edit
	    x: 534
	    y: 0
	    width: 240
	    height: 60
	    fontSize: 34
	    text: page.state == "sellprice_edit" ? "Assign" : "Edit"
	    onButtonClick: { if (page.state == "sellprice_edit") page.state = "normal"; else page.state = "sellprice_edit"; }
	}
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
	    font.pointSize: 34
	}

	Text {
	    id: item_balance
	    x: 200
	    y: 0
	    height: 60
	    width: 248
	    color: "#ffff7c"
	    text: info.balance
	    horizontalAlignment: Text.AlignRight
	    verticalAlignment: Text.AlignVCenter
	    font.pointSize: 34
	}

	BarButton {
	    id: item_balance_restock
	    x: 534
	    y: 0
	    width: 240
	    height: 60
	    fontSize: 34
	    text: page.state == "balance_edit" ? "Add qty" : "Restock"
	    onButtonClick: {
		if (page.state == "balance_edit") {
		    /* TODO: Add... */
		    page.state = "normal";
		} else
		    page.state = "balance_edit";
	    }
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
        text: "Save"
        onButtonClick: {
	    info["name"] = name
            shop.saveAccount(dbid, info)
            status_text.setStatus("Changes saved", "#ffff7c")
            loadPage("StockMgmt")
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
	info = shop.loadAccount(dbid)
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
