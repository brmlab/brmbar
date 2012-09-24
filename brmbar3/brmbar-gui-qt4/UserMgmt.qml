// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtQuick 1.0

Item {
    id: page
    anchors.fill: parent

    property variant name: ""
    property variant dbid: ""
    property variant price: ""
    property variant user_list_model

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
            loadPage("UserEdit", { name: acct["name"], dbid: acct["id"], negbalance: acct["negbalance"] })
        }
    }

    Item {
	id: user_list_container
        x: 65
        y: 156
        width: 899
        height: 250

	ListView {
	    id: user_list
	    anchors.fill: parent
	    clip: true
	    delegate: Item {
		x: 5
		height: 80

		Text {
		    text: modelData.name
		    anchors.verticalCenter: parent.verticalCenter
		    color: "#ffffff"
		    font.pointSize: 34
		}

		Text {
		    anchors.verticalCenter: parent.verticalCenter
		    x: 300
		    width: 254
		    color: "#ffff7c"
		    text: modelData.negbalance_str
		    horizontalAlignment: Text.AlignRight
		    font.pointSize: 34
		}

		BarButton {
		    anchors.verticalCenter: parent.verticalCenter
		    x: 600
		    width: 240
		    height: 68
		    text: "Withdraw"
		    fontSize: 34
		}
	    }
	    model: user_list_model
	}

	BarScrollBar {
	    id: user_list_scrollbar
	    anchors.right: parent.right
	    anchors.rightMargin: 0
	    flickableItem: user_list
	}
    }

    BarButton {
        id: add_user
        x: 65
        y: 582
        width: 360
        text: "Add User"
        fontSize: 44
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
	user_list_model = shop.userList()
    }
}