// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtQuick 1.0

Item {
    id: page
    anchors.fill: parent

    property variant item_list_model

    BarcodeInput {
        color: "#00ff00" /* just for debugging */
        onAccepted: {
            var acct = shop.barcodeInput(text)
            text = ""
            if (typeof(acct) == "undefined") {
                status_text.setStatus("Unknown barcode", "#ff4444")
                return
            }
            if (acct.acctype != "inventory") {
                loadPageByAcct(acct)
                return
            }
            loadPage("ItemEdit", { dbid: acct["id"] })
        }
    }

    Item {
	id: item_list_container
        x: 65
        y: 166
        width: 899
        height: 400

	ListView {
	    id: item_list
	    anchors.fill: parent
	    clip: true
	    delegate: Item {
		x: 5
		height: 80

		Text {
		    text: modelData.name
		    anchors.verticalCenter: parent.verticalCenter
		    color: "#ffffff"
		    font.pixelSize: 0.768 * 46
		}

		Text {
		    anchors.verticalCenter: parent.verticalCenter
		    x: 300
		    width: 254
		    color: "#ffff7c"
		    text: modelData.price
		    horizontalAlignment: Text.AlignRight
		    font.pixelSize: 0.768 * 46
		}

		BarButton {
		    anchors.verticalCenter: parent.verticalCenter
		    x: 600
		    width: 240
		    height: 68
		    text: "Edit"
		    fontSize: 0.768 * 46
		    onButtonClick: {
			loadPage("ItemEdit", { dbid: modelData.id })
		    }
		}
	    }
	    model: item_list_model
	}

	BarScrollBar {
	    id: item_list_scrollbar
	    anchors.right: parent.right
	    anchors.rightMargin: 0
	    flickableItem: item_list
	}
    }

    BarButton {
        id: new_item
        x: 65
        y: 582
        width: 360
        text: "New Item"
        fontSize: 0.768 * 60
        onButtonClick: {
	    loadPage("ItemEdit", { dbid: "" })
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

    Component.onCompleted: {
	item_list_model = shop.itemList()
    }
}
