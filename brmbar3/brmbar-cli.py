#!/usr/bin/python3

import sys
import psycopg2

import brmbar

db = psycopg2.connect("dbname=brmbar")
shop = brmbar.Shop.new_with_defaults(db)
currency = shop.currency

active_inv_item = None
active_credit = None

for line in sys.stdin:
	barcode = line.rstrip()

	if barcode[0] == "$":
		credits = {'$02': 20, '$05': 50, '$10': 100, '$20': 200, '$50': 500, '$1k': 1000}
		credit = credits[barcode]
		if credit is None:
			print("Unknown barcode: " + barcode)
			continue
		print("CREDIT " + str(credit))
		active_inv_item = None
		active_credit = credit
		continue

	if barcode == "SCR":
		print("SHOW CREDIT")
		active_inv_item = None
		active_credit = None
		continue

	acct = brmbar.Account.load_by_barcode(db, barcode)
	if acct is None:
		print("Unknown barcode: " + barcode)
		continue
	
	if acct.acctype == 'debt':
		if active_inv_item is not None:
			cost = shop.sell(item = active_inv_item, user = acct)
			print("{} has bought {} for {} and now has {} balance".format(acct.name, active_inv_item.name, currency.str(cost), acct.negbalance_str()))
		elif active_credit is not None:
			shop.add_credit(credit = active_credit, user = acct)
			print("{} has added {} credit and now has {} balance".format(acct.name, currency.str(active_credit), acct.negbalance_str()))
		else:
			print("{} has {} balance".format(acct.name, acct.negbalance_str()))
		active_inv_item = None
		active_credit = None

	elif acct.acctype == 'inventory':
		buy, sell = acct.currency.rates(currency)
		print("{} costs {} with {} in stock".format(acct.name, currency.str(sell), int(acct.balance())))
		active_inv_item = acct
		active_credit = None

	else:
		print("invalid account type {}".format(acct.acctype))
		active_inv_item = None
		active_credit = None
