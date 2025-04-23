#!/usr/bin/python3

import sys
import subprocess

#from brmbar import Database
#from brmbar import Currency

from contextlib import closing
import psycopg2
from brmbar.Database import Database
from brmbar.Currency import Currency
import math

#import brmbar



def approx_equal(a, b, tol=1e-6):
    """Check if two (buy, sell) rate tuples are approximately equal."""
    return (
        isinstance(a, tuple) and isinstance(b, tuple) and
        math.isclose(a[0], b[0], abs_tol=tol) and
        math.isclose(a[1], b[1], abs_tol=tol)
    )

def compare_exceptions(e1, e2):
    """Compare exception types and messages."""
    return type(e1) == type(e2) and str(e1) == str(e2)

def main():
    db = Database("dbname=brmbar")

    # Get all currencies
    with closing(db.db_conn.cursor()) as cur:
        cur.execute("SELECT id, name FROM currencies")
        currencies = cur.fetchall()

    # Build Currency objects
    currency_objs = [Currency(db, id, name) for id, name in currencies]

    # Test all currency pairs
    for c1 in currency_objs:
        for c2 in currency_objs:
            #if c1.id == c2.id:
            #    continue

            try:
                rates1 = c1.rates(c2)
                exc1 = None
            except (RuntimeError, NameError) as e1:
                rates1 = None
                exc1 = e1

            try:
                rates2 = c1.rates2(c2)
                exc2 = None
            except (RuntimeError, NameError) as e2:
                rates2 = None
                exc2 = e2

            if exc1 or exc2:
                if not compare_exceptions(exc1, exc2):
                    print(f"[EXCEPTION DIFFERENCE] {c1.name} -> {c2.name}")
                    print(f"  rates() exception:  {type(exc1).__name__}: {exc1}")
                    print(f"  rates2() exception: {type(exc2).__name__}: {exc2}")
            elif not approx_equal(rates1, rates2):
                print(f"[VALUE DIFFERENCE] {c1.name} -> {c2.name}")
                print(f"  rates():  {rates1}")
                print(f"  rates2(): {rates2}")
            else:
                print(f"{c1.name} -> {c2.name} {rates1} {rates2} OK")

if __name__ == "__main__":
    main()
