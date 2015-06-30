#!/usr/bin/python

import sys

from brmbar import Database

import brmbar

from flask import *
app = Flask(__name__)
#app.debug = True

@app.route('/stock/')
def stock(show_all=False):
    # TODO: Use a fancy template.
    # FIXME: XSS protection.
    response = '<table border="1"><tr><th>Id</th><th>Item Name</th><th>Bal.</th></tr>'
    for a in shop.account_list("inventory"):
        style = ''
        balance = a.balance()
        if balance == 0:
            if not show_all:
                continue
            style = 'color: grey; font-style: italic'
        elif balance < 0:
            style = 'color: red'
        response += '<tr style="%s"><td>%d</td><td>%s</td><td>%d</td></tr>' % (style, a.id, a.name, balance)
    response += '</table>'
    if show_all:
        response += '<p><a href=".">(hide out-of-stock items)</a></p>'
    else:
        response += '<p><a href="all">(show all items)</a></p>'
    return response

@app.route('/stock/all')
def stockall():
    return stock(show_all=True)


db = Database.Database("dbname=brmbar")
shop = brmbar.Shop.new_with_defaults(db)
currency = shop.currency

if __name__ == '__main__':
    app.run(host='0.0.0.0')
