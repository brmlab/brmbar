#!/usr/bin/python3

import sys

from brmbar import Database

import brmbar


def help():
    print("""BrmBar v3 (c) Petr Baudis <pasky@ucw.cz> 2012-2013

Usage: brmbar-cli.py COMMAND ARGS...

1. Commands pertaining the standard operation
	showcredit USER
	changecredit USER +-AMT
	sellitem USER ITEM +-AMT
		You can use negative AMT to undo a sale.
	restock ITEM AMT
 	userinfo USER
	iteminfo ITEM

2. Management commands
	listusers
		List all user accounts in the system.
	listitems
		List all item accounts in the system.
	stats
		A set of various balances as shown in the Management
		screen of the GUI.
	adduser USER
		Add user (debt) account with given username.
	undo TRANSID
		Commit a transaction that reverses all splits of a transaction with
		a given id (to find out that id: select * from transaction_cashsums;)

3. Inventorization

	inventory ITEM1 NEW_AMOUNT1 ITEM2 NEW_AMOUNT2
		Inventory recounting (fixing the number of items)
	inventory-interactive
		Launches interactive mode for performing inventory with barcode reader
	changecash AMT
		Fixes the cash and puts money difference into excess or deficit account
	consolidate
		Wraps up inventory + cash recounting, transferring the excess and
		deficit accounts balance to the profits account and resetting them

USER and ITEM may be barcodes or account ids. AMT may be
both positive and negative amount (big difference to other
user interfaces; you can e.g. undo a sale!).

For users, you can use their name as USER as their username
is also the barcode. For items, use listitems command first
to find out the item id.""")
    sys.exit(1)


def load_acct(inp):
    acct = None
    if inp.isdigit():
        acct = brmbar.Account.load(db, id = inp)
    if acct is None:
        acct = brmbar.Account.load_by_barcode(db, inp)
    if acct is None:
        print("Cannot map account " + inp, file=sys.stderr)
        exit(1)
    return acct

def load_user(inp):
    acct = load_acct(inp)
    if acct.acctype != "debt":
        print("Bad account " + inp + " type " + acct.acctype, file=sys.stderr)
        exit(1)
    return acct

def load_item(inp):
    acct = load_acct(inp)
    if acct.acctype != "inventory":
        print("Bad account " + inp + " type " + acct.acctype, file=sys.stderr)
        exit(1)
    return acct


db = Database.Database("dbname=brmbar")
shop = brmbar.Shop.new_with_defaults(db)
currency = shop.currency

if len(sys.argv) <= 1:
    help()


if sys.argv[1] == "showcredit":
    acct = load_user(sys.argv[2])
    print("{}: {}".format(acct.name, acct.negbalance_str()))

elif sys.argv[1] == "changecredit":
    acct = load_user(sys.argv[2])
    amt = int(sys.argv[3])
    if amt > 0:
        shop.add_credit(credit = amt, user = acct)
    elif amt < 0:
        shop.withdraw_credit(credit = -amt, user = acct)
    print("{}: {}".format(acct.name, acct.negbalance_str()))

elif sys.argv[1] == "sellitem":
    uacct = load_user(sys.argv[2])
    iacct = load_item(sys.argv[3])
    amt = int(sys.argv[4])
    if amt > 0:
        shop.sell(item = iacct, user = uacct, amount = amt)
    elif amt < 0:
        shop.undo_sale(item = iacct, user = uacct, amount = -amt)
    print("{}: {}".format(uacct.name, uacct.negbalance_str()))
    print("{}: {}".format(iacct.name, iacct.balance_str()))

elif sys.argv[1] == "userinfo":
    acct = load_user(sys.argv[2])
    print("{} (id {}): {}".format(acct.name, acct.id, acct.negbalance_str()))

    res = db.execute_and_fetchall("SELECT barcode FROM barcodes WHERE account = %s", [acct.id])
    print("Barcodes: " + ", ".join(map((lambda r: r[0]), res)))

elif sys.argv[1] == "iteminfo":
    acct = load_item(sys.argv[2])
    print("{} (id {}): {} pcs".format(acct.name, acct.id, acct.balance()))

    (buy, sell) = acct.currency.rates(currency)
    print("Buy: " + currency.str(buy) + "  Sell: " + currency.str(sell));

    res = db.execute_and_fetchall("SELECT barcode FROM barcodes WHERE account = %s", [acct.id])
    print("Barcodes: " + ", ".join(map((lambda r: r[0]), res)))

elif sys.argv[1] == "listusers":
    for acct in shop.account_list("debt"):
        print("{}\t{}\t{}".format(acct.name, acct.id, acct.negbalance_str()))

elif sys.argv[1] == "listitems":
    for acct in shop.account_list("inventory"):
        print("{}\t{}\t{} pcs".format(acct.name, acct.id, acct.balance()))

elif sys.argv[1] == "stats":
    print("Cash: {}".format(shop.cash.balance_str()))
    print("Profit: {}".format(shop.profits.balance_str()))
    print("Credit: {}".format(shop.credit_negbalance_str()))
    print("Inventory: {}".format(shop.inventory_balance_str()))
    print("Excess: {}".format(shop.excess.negbalance_str()))
    print("Deficit: {}".format(shop.deficit.balance_str()))

elif sys.argv[1] == "adduser":
    acct = brmbar.Account.create(db, sys.argv[2], brmbar.Currency.load(db, id = 1), 'debt')
    acct.add_barcode(sys.argv[2]) # will commit
    print("{}: id {}".format(acct.name, acct.id));

elif sys.argv[1] == "undo":
    newtid = shop.undo(int(sys.argv[2]))
    print("Transaction %d undone by reverse transaction %d" % (int(sys.argv[2]), newtid))

elif sys.argv[1] == "inventory":
    if (len(sys.argv) % 2 != 0 or len(sys.argv) < 4):
        print ("Invalid number of parameters, count your parameters.")
    else:
        for i in range(2, len(sys.argv), 2):
            iacct = load_item(sys.argv[i])
            iamt = int(sys.argv[i+1])
            print("Current state {} (id {}): {} pcs".format(iacct.name, iacct.id, iacct.balance()))
            if shop.fix_inventory(item = iacct, amount = iamt):
                print("New state {} (id {}): {} pcs".format(iacct.name, iacct.id, iacct.balance()))
            else:
                print ("No action needed amount is correct.")


elif sys.argv[1] == "inventory-interactive":
    print("Inventory interactive mode. To exit interactive mode just enter empty barcode")

    while True:
        barcode = str(input("Enter barcode:"))
        fuckyou = input("fuckyou")
        if barcode == "":
            break
        iacct = brmbar.Account.load_by_barcode(db, barcode)
        amount = str(input("What is the amount of {} in reality (expected: {} pcs):".format(iacct.name, iacct.balance())))
        if amount == "":
            break
        elif int(amount) > 10000:
            print("Ignoring too high amount {}, assuming barcode was mistakenly scanned instead".format(amount))
        else:
            iamt = int(amount)
            print("Current state {} (id {}): {} pcs".format(iacct.name, iacct.id, iacct.balance()))
            if shop.fix_inventory(item = iacct, amount = iamt):
                print("New state {} (id {}): {} pcs".format(iacct.name, iacct.id, iacct.balance()))
            else:
                print("No action needed, amount is correct.")
    print("End of processing. Bye")

elif sys.argv[1] == "changecash":
    if (len(sys.argv) != 3):
        print ("Invalid number of parameters, check your parameters.")
    else:
        print("Current Cash is : {}".format(shop.cash.balance_str()))
        iamt = int(sys.argv[2])
        if shop.fix_cash(amount = iamt):
            print("New Cash is : {}".format(shop.cash.balance_str()))
        else:
            print ("No action needed amount is the same.")

elif sys.argv[1] == "consolidate":
    if (len(sys.argv) != 2):
        print ("Invalid number of parameters, check your parameters.")
    else:
        shop.consolidate()

elif sys.argv[1] == "restock":
    if (len(sys.argv) != 4):
        print ("Invalid number of parameters, check your parameters.")
    else:
        iacct = load_item(sys.argv[2])
        oldbal = iacct.balance()
        amt = int(sys.argv[3])
        cash = shop.buy_for_cash(iacct, amt);
        print("Old amount {}, increased by {}, take {} from cashbox".format(oldbal, amt, cash))
       

else:
    help()
