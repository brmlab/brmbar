import QtQuick 1.1

Item {
    id: page
    anchors.fill: parent

    property variant cash: shop.balance_cash()
    property variant profit: shop.balance_profit()
    property variant inv_money: shop.balance_inventory()
    property variant credit_money: shop.balance_credit()

    Text {
        id: profit_name
        x: 65
        y: 156
        width: 337
        height: 160
        color: "#ffffff"
        text: "Profit:"
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 0.768 * 46
    }

    Text {
        id: profit_amount
        x: 215
        y: 156
        height: 160
        width: 254
        color: "#ffff7c"
        text: parent.profit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.pixelSize: 0.768 * 46
    }

    Text {
        id: cash_name
        x: 65
        y: 266
        width: 337
        height: 160
        color: "#ffffff"
        text: "Cash:"
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 0.768 * 46
    }

    Text {
        id: cash_amount
        x: 215
        y: 266
        height: 160
        width: 254
        color: "#ffff7c"
        text: parent.cash
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.pixelSize: 0.768 * 46
    }

    Text {
        id: credit_name
        x: 535
        y: 156
        width: 337
        height: 160
        color: "#ffffff"
        text: "Credit:"
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 0.768 * 46
    }

    Text {
        id: credit_amount
        x: 705
        y: 156
        height: 160
        width: 254
        color: "#ffff7c"
        text: parent.credit_money
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.pixelSize: 0.768 * 46
    }

    Text {
        id: inv_name
        x: 535
        y: 266
        width: 337
        height: 160
        color: "#ffffff"
        text: "Stock:"
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 0.768 * 46
    }

    Text {
        id: inv_amount
        x: 705
        y: 266
        height: 160
        width: 254
        color: "#ffff7c"
        text: parent.inv_money
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.pixelSize: 0.768 * 46
    }

    BarButton {
        id: stock_manager
        x: 65
        y: 430
        width: 360
        text: "Stock Mgmt"
        onButtonClick: {
            loadPage("StockMgmt")
        }
    }

    BarButton {
        id: user_manager
        x: 599
        y: 430
        width: 360
        text: "User Mgmt"
        onButtonClick: {
            loadPage("UserMgmt")
        }
    }

    BarButton {
        id: select_item
        x: 65
        y: 582
        width: 360
        text: "Receipt"
        onButtonClick: {
            loadPage("Receipt")
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
}
