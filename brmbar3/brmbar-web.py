#!/usr/bin/python3

import sys

from brmbar import Database

import brmbar

from flask import *
app = Flask(__name__)
#app.debug = True

@app.route('/stock')
def stock():
    # TODO: Use a fancy template.
    # FIXME: XSS protection.
    response = '<table border="1"><tr><th>Id</th><th>Item Name</th><th>Bal.</th></tr>'
    for a in shop.account_list("inventory"):
        response += '<tr><td>%d</td><td>%s</td><td>%d</td></tr>' % (a.id, a.name, a.balance())
    response += '</table>'
    return response


db = Database.Database("dbname=brmbar")
shop = brmbar.Shop.new_with_defaults(db)
currency = shop.currency

if __name__ == '__main__':
    app.run()
