#!/usr/bin/python3

import sys

from PySide import QtCore, QtGui, QtDeclarative

from brmbar import Database

import brmbar


class ShopAdapter(QtCore.QObject):
    """ Interface between QML and the brmbar package """
    def __init__(self):
        QtCore.QObject.__init__(self)

    def acct_debt_map(self, acct):
        map = acct.__dict__.copy()
        map["balance"] = str(acct.balance())
        map["negbalance"] = str(-acct.balance())
        map["negbalance_str"] = acct.negbalance_str()
        return map

    def acct_inventory_map(self, acct):
        buy, sell = acct.currency.rates(currency)
        map = acct.__dict__.copy()
        map["balance"] = "{:.0f}".format(acct.balance())
        map["buy_price"] = str(buy)
        map["price"] = str(sell)
        return map

    def acct_cash_map(self, acct):
        map = acct.__dict__.copy()
        return map

    def acct_map(self, acct):
        if acct is None:
            return None
        if acct.acctype == 'debt':
            return self.acct_debt_map(acct)
        elif acct.acctype == "inventory":
            return self.acct_inventory_map(acct)
        elif acct.acctype == "cash":
            return self.acct_cash_map(acct)
        else:
            return None

    @QtCore.Slot(str, result='QVariant')
    def barcodeInput(self, barcode):
        """ Evaluate barcode received on input

        Normally, we would return just the account object, but
        passing that to QML appears to be very non-trivial.
        Therefore, we construct a map that we can pass around easily.
        We return None on unrecognized barcode. """
        barcode = str(barcode)
        if barcode and barcode[0] == "$":
            credits = {'$02': 20, '$05': 50, '$10': 100, '$20': 200, '$50': 500, '$1k': 1000}
            credit = credits[barcode]
            if credit is None:
                return None
            return { "acctype": "recharge", "amount": str(credit)+".00" }
        acct = self.acct_map(brmbar.Account.load_by_barcode(db, barcode))
        db.commit()
        return acct

    @QtCore.Slot('QVariant', result='QVariant')
    def loadAccount(self, dbid):
        acct = self.acct_map(brmbar.Account.load(db, id = dbid))
        db.commit()
        return acct

    @QtCore.Slot('QVariant', 'QVariant', result='QVariant')
    def sellItem(self, itemid, userid):
        user = brmbar.Account.load(db, id = userid)
        shop.sell(item = brmbar.Account.load(db, id = itemid), user = user)
        balance = user.negbalance_str()
        db.commit()
        return balance

    @QtCore.Slot('QVariant', result='QVariant')
    def sellItemCash(self, itemid):
        shop.sell_for_cash(item = brmbar.Account.load(db, id = itemid))
        db.commit()

    @QtCore.Slot('QVariant', 'QVariant', result='QVariant')
    def chargeCredit(self, credit, userid):
        user = brmbar.Account.load(db, id = userid)
        shop.add_credit(credit = credit, user = user)
        balance = user.negbalance_str()
        db.commit()
        return balance

    @QtCore.Slot('QVariant', 'QVariant', result='QVariant')
    def withdrawCredit(self, credit, userid):
        user = brmbar.Account.load(db, id = userid)
        shop.withdraw_credit(credit = credit, user = user)
        balance = user.negbalance_str()
        db.commit()
        return balance

    @QtCore.Slot(result='QVariant')
    def balance_cash(self):
        balance = shop.cash.balance_str()
        db.commit()
        return balance
    @QtCore.Slot(result='QVariant')
    def balance_profit(self):
        balance = shop.profits.balance_str()
        db.commit()
        return balance
    @QtCore.Slot(result='QVariant')
    def balance_inventory(self):
        balance = shop.inventory_balance_str()
        db.commit()
        return balance
    @QtCore.Slot(result='QVariant')
    def balance_credit(self):
        balance = shop.credit_negbalance_str()
        db.commit()
        return balance

    @QtCore.Slot(result='QVariant')
    def userList(self):
        alist = [ self.acct_debt_map(a) for a in shop.account_list("debt") ]
        db.commit()
        return alist

    @QtCore.Slot('QVariant', result='QVariant')
    def itemList(self, query):
        alist = [ self.acct_inventory_map(a) for a in shop.account_list("inventory", like_str="%%"+query+"%%") ]
        db.commit()
        return alist

    @QtCore.Slot('QVariant', 'QVariant', result='QVariant')
    def addBarcode(self, dbid, barcode):
        acct = brmbar.Account.load(db, id = dbid).add_barcode(barcode)
        db.commit()
        return acct

    @QtCore.Slot('QVariant', 'QVariant', result='QVariant')
    def saveItem(self, dbid, invmap):
        acct = brmbar.Account.load(db, id = dbid)
        if (acct.name != invmap["name"]):
            acct.rename(invmap["name"])
        buy, sell = acct.currency.rates(currency)
        if (sell != invmap["price"]):
            acct.currency.update_sell_rate(currency, invmap["price"])
        if (buy != invmap["buy_price"]):
            acct.currency.update_buy_rate(currency, invmap["buy_price"])
        cost = ""
        if (acct.balance() < int(invmap["balance"])):
            cost = shop.buy_for_cash(acct, invmap["balance"] - acct.balance())
        else:
            db.commit()
        return { "dbid": dbid, "cost": (currency.str(cost) if cost != "" else "") }

    @QtCore.Slot('QVariant', result='QVariant')
    def newItem(self, invmap):
        if (invmap["name"] == "" or invmap["price"] == "" or invmap["buy_price"] == ""):
            return None
        invcurrency = brmbar.Currency.create(db, invmap["name"])
        invcurrency.update_sell_rate(currency, invmap["price"])
        invcurrency.update_buy_rate(currency, invmap["buy_price"])
        acct = brmbar.Account.create(db, invmap["name"], invcurrency, "inventory")
        cost = ""
        if (int(invmap["balance"]) > 0):
            cost = shop.buy_for_cash(acct, invmap["balance"]) # implicit db.commit()
        else:
            db.commit()
        return { "dbid": acct.id, "cost": (currency.str(cost) if cost != "" else "") }

    @QtCore.Slot('QVariant', 'QVariant', 'QVariant', result='QVariant')
    def newReceipt(self, userid, description, amount):
        if (description == "" or amount == ""):
            return None
        user = brmbar.Account.load(db, id = userid)
        shop.receipt_to_credit(user, amount, description)
        balance = user.negbalance_str()
        db.commit()
        return balance

db = Database.Database("dbname=brmbar")
shop = brmbar.Shop.new_with_defaults(db)
currency = shop.currency
db.commit()


app = QtGui.QApplication(sys.argv)
view = QtDeclarative.QDeclarativeView()

ctx = view.rootContext()
ctx.setContextProperty('shop', ShopAdapter())

view.setSource('brmbar-gui-qt4/main.qml')

view.showFullScreen()
app.exec_()
