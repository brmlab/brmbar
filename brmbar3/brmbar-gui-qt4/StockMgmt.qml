import QtQuick 1.1

Item {
    id: page
    anchors.fill: parent

    property variant item_list_model

    state: "normal"

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
        width: 1155
        height: 656

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
		    x: 556
		    width: 254
		    color: "#ffff7c"
		    text: modelData.price
		    horizontalAlignment: Text.AlignRight
		    font.pixelSize: 0.768 * 46
		}

		BarButton {
		    anchors.verticalCenter: parent.verticalCenter
		    x: 856
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
        y: 838
        width: 281
        height: 83
        text: "New Item"
        fontSize: 0.768 * 60
        visible: page.state == "normal"
        onButtonClick: {
	    loadPage("ItemEdit", { dbid: "" })
	}
    }

    BarButton {
        id: cancel
        x: 855
        y: 838
        width: 360
        text: "Main Screen"
        onButtonClick: {
            if (page.state == "search")
                page.state = "normal"
            else
                loadPage("MainPage")
	}
    }

    BarButton {
        id: search_button
        x: 353
        y: 838
        text: "Search"
        visible: page.state == "normal"
        onButtonClick: { page.state = "search" }
    }

    BarKeyPad {
        id: search_pad
        x: 193
        y: 554
        opacity: 0
    }

    Text {
        id: search_text
        x: 65
        y: 602
        color: "#ffff7c"
        text: search_pad.enteredText
        visible: page.state == "search"
        font.pixelSize: 0.768 * 46
        opacity: 0
    }

    BarButton {
        id: query_button
        x: 353
        y: 838
        text: "Search"
        visible: page.state == "search"
        onButtonClick: {
            page.item_list_model = shop.itemList(search_pad.enteredText)
            item_list.model = page.item_list_model
        }
    }

    states: [
        State {
            name: "normal"
        },
        State {
            name: "search"

            PropertyChanges {
                target: item_list_container
                x: 66
                y: 166
                width: 1155
                height: 348
            }

            PropertyChanges {
                target: search_pad
                x: 83
                y: 514
                opacity: 1
            }

            PropertyChanges {
                target: cancel
                text: "Back"
            }

            PropertyChanges {
                target: search_text
                x: 65
                y: 838
                width: 528
                height: 83
                opacity: 1
            }
        }
    ]

    Component.onCompleted: {
        item_list_model = shop.itemList("")
    }
}
