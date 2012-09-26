// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtQuick 1.0

Item {
    id: page
    anchors.fill: parent

    property variant name: ""
    property variant dbid: ""
    property variant info: ""

    Text {
        id: item_name
        x: 65
        y: 166
        width: 537
        height: 60
        color: "#ffff7c"
        text: parent.name
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 34
    }

    BarButton {
        id: item_name_edit
        x: 599
        y: 166
        width: 240
        height: 60
        fontSize: 34
        text: "Edit"
    }

    Text {
        id: item_buyprice_label
        x: 65
        y: 236
        height: 60
        width: 200
        color: "#ffffff"
        text: "Buy price:"
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 34
    }

    Text {
        id: item_buyprice
        x: 265
        y: 236
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
        x: 599
        y: 236
        width: 240
        height: 60
        fontSize: 34
        text: "Edit"
    }

    Text {
        id: item_sellprice_label
        x: 65
        y: 306
        height: 60
        width: 200
        color: "#ffffff"
        text: "Sell price:"
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 34
    }

    Text {
        id: item_sellprice
        x: 265
        y: 306
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
        x: 599
        y: 306
        width: 240
        height: 60
        fontSize: 34
        text: "Edit"
    }

    Text {
        id: item_balance_label
        x: 65
        y: 376
        height: 60
        width: 200
        color: "#ffffff"
        text: "Quantity:"
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 34
    }

    Text {
        id: item_balance
        x: 265
        y: 376
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
        x: 599
        y: 376
        width: 240
        height: 60
        fontSize: 34
        text: "Restock"
    }

    BarButton {
        id: add_barcode
        x: 65
        y: 476
        width: 360
        text: "Add Barcode"
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
}
