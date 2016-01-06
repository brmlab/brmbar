Quick Guide
-----------

* I want to buy for cash: I scan item's barcode, press **Pay by Cash** and pour
  money into the cash box.

* I want to buy from credit: I scan item's barcode, then my barcode.
(If you don't have your barcode printed out, you can also type your
username on a physical keyboard.)

* I want to put money on credit: press **Charge**, I scan my barcode,
type some amount, press **Charge** and put money in the cash box.


Advanced Operations
-------------------

* I want to withdraw funds from my (positive) credit:
Press **Management**, choose **User Mgmt**, scan your barcode,
press the Withdraw Amount and type the amount. Then take the money
from the cash box.

* I want to stock in some inventory (that's been in brmbar before):
Press **Management**, **Stock Mgmt**, scan barcode of the item, edit
the purchase price (or also the selling price and label), press
**Restock** and enter the quantity of stocked in piece. Press **Save**.
Toss the bill (if possible with the current written date, to allow
pairing) to brmbar.

* I want to stock in some new inventory: Press **Management**, **Stock
Mgmt**, press **Add new item**, enter the name, purchase and selling price,
press **Create**. Then press **Restock**, enter the quantity stocked in.
Scan the item's barcode and press **Save**. Toss the bill in brmbar.

* I want to bill the brmbar with some small expenses like duct tape:
Press **Management** and **Receipt**. Press **Description** and write
a brief description of the bill. Press **Edit** near the **Money Amount**
and enter the amount. Scan *your* barcode. The operation is finished
by pressing **Create**. Toss bill (inscribed with the current date
to ease pairing) to brmbar.


General Notes
-------------

The system expects that we take money from the cash box right away.
If you don't want to (or there is e.g. not enough money), put money
on your credit account instead (see above).  Please always do that
(never *I'll remember and I'll take money later*) so that there is
a record that the cash box and system records are not in sync and
there are no irregularities.

To enter text (or numbers too), you can use both the on-screen keyboard
and the physical keyboard nearby.


Administrative Usage
--------------------

* The most common administrative action you will need to do is adding
  new user (also called debt or credit) accounts. The GUI support for
  this is not implemented yet, but the `brmbar-cli.py` UI allows it:

  		./brmbar-cli.py adduser joehacker

  Afterwards, print out a barcode saying "joehacker" and stick that
  somewhere nearby; scanning that barcode will allow access to this
  account (and so will typing "joehacker" on a physical keyboard).

* If your inventory stock count or cash box amount does not match
  the in-system data, you will need to make a corrective transaction.
  To fix cash amount to reality in which you counted 1234Kč, use

		./brmbar-cli.py fixcash 1234

  whereas to fix amount of a particular stock, use

		./brmbar-cli.py inventory-interactive

  then scan the item barcode and then enter the right amount.

* If you want to view recent transactions, run

		psql brmbar
		select * from transaction_cashsums;

* If you want to undo a transaction, get its id (using the select above)
  and run

		./brmbar-cli.py undo ID


Useful SQL queries
------------------

* Compute sum of sold stock:

		select sum(amount) from transactions
			left join transaction_splits on transaction_splits.transaction = transactions.id
			where description like '% sale %' and side = 'debit';

* List of items not covered by inventory check:

		select * from account_balances
			where id not in (select account from transactions
				left join transaction_splits on transaction_splits.transaction = transactions.id
				where description like '% inventory %')
			and acctype = 'inventory';

* List all cash transactions:

		select time, transactions.id, description, responsible, amount from transactions
			left join transaction_splits on transaction_splits.transaction = transactions.id
			where transaction_splits.account = 1;

* List all inventory items ordered by their cummulative worth:

		select foo.*, foo.rate * -foo.crbalance as worth from
			(select account_balances.*,
				(select exchange_rates.rate from exchange_rates, accounts
					where exchange_rates.target = accounts.currency
						and accounts.id = account_balances.id
					order by exchange_rates.valid_since limit 1) as rate
				from account_balances where account_balances.acctype = 'inventory')
			as foo order by worth;

