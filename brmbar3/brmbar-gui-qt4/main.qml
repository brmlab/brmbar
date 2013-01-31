import QtQuick 1.1

BasePage {
    id: canvas

    property variant page: Qt.createComponent("MainPage.qml").createObject(canvas)
    function loadPage(name, properties) {
        status_text.hideStatus()
        name += ".qml"
        page.destroy();
        if (typeof(properties) == "undefined") {
            page = Qt.createComponent(name).createObject(canvas)
        } else {
            page = Qt.createComponent(name).createObject(canvas, properties)
        }
    }

    function loadPageByAcct(acct) {
        if (acct.acctype === "inventory") {
            loadPage("ItemInfo", { name: acct["name"], dbid: acct["id"], price: acct["price"] })
        } else if (acct.acctype === "debt") {
            loadPage("UserInfo", { name: acct["name"], dbid: acct["id"], negbalance: acct["negbalance"] })
        } else if (acct.acctype === "recharge") {
            loadPage("ChargeCredit", { amount: acct["amount"] })
        }
    }
}
