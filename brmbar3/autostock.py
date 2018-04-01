#! /usr/bin/env python3

import argparse
import brmbar
import math
from brmbar import Database

def main():
    parser = argparse.ArgumentParser(usage = "File format: EAN amount total_price name, e.g. 4001242002377 6 167.40 Chio Tortillas")
    parser.add_argument("filename")
    args = parser.parse_args()

    db = Database.Database("dbname=brmbar")
    shop = brmbar.Shop.new_with_defaults(db)
    currency = shop.currency

    # ...
    total = 0
    with open(args.filename) as fin:
        for line in fin:
            split = line.split(" ")
            ean, amount, price_total, name = split[0], int(split[1]), float(split[2]), " ".join(split[3:])
            name = name.strip()

            price_buy = price_total / amount
            acct = brmbar.Account.load_by_barcode(db, ean)
            if not acct:
                print("Creating account for EAN {} '{}'".format(ean, name))
                invcurr = brmbar.Currency.create(db, name)
                acct = brmbar.Account.create(db, name, invcurr, "inventory")
                acct.add_barcode(ean)
            price_sell = max(math.ceil(price_buy * 1.15), price_buy)
            acct.currency.update_sell_rate(currency, price_sell)
            acct.currency.update_buy_rate(currency, price_buy)
            cash = shop.buy_for_cash(acct, amount)
            total += cash
            print("Increased by {}, take {} from cashbox".format(amount, cash))
    print("Total is {}".format(total))

if __name__ == "__main__":
    main()

