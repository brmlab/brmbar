import brmbar
from .Currency import Currency
from .Account import Account

import psycopg2
from contextlib import closing

class Shop:
	""" BrmBar Shop

	Business logic so that only interaction is left in the hands
	of the frontend scripts. """
	def __init__(self, db, currency, profits, cash):
		self.db = db
		self.currency = currency # brmbar.Currency
		self.profits = profits # income brmbar.Account for brmbar profit margins on items
		self.cash = cash # our operational ("wallet") cash account

	@classmethod
	def new_with_defaults(cls, db):
		return cls(db,
			currency = Currency.default(db),
			profits = Account.load(db, name = "BrmBar Profits"),
			cash = Account.load(db, name = "BrmBar Cash"))

	def sell(self, item, user, amount = 1):
		# Sale: Currency conversion from item currency to shop currency
		(buy, sell) = item.currency.rates(self.currency)
		cost = amount * sell
		profit = amount * (sell - buy)

		transaction = self._transaction(responsible = user, description = "BrmBar sale of {}x {} to {}".format(amount, item.name, user.name))
		item.credit(transaction, amount, user.name)
		user.debit(transaction, cost, item.name) # debit (increase) on a _debt_ account
		self.profits.debit(transaction, profit, "Margin on " + item.name)
		self.db.commit()

		return cost

	def sell_for_cash(self, item, amount = 1):
		# Sale: Currency conversion from item currency to shop currency
		(buy, sell) = item.currency.rates(self.currency)
		cost = amount * sell
		profit = amount * (sell - buy)

		transaction = self._transaction(description = "BrmBar sale of {}x {} for cash".format(amount, item.name))
		item.credit(transaction, amount, "Cash")
		self.cash.debit(transaction, cost, item.name)
		self.profits.debit(transaction, profit, "Margin on " + item.name)
		self.db.commit()

		return cost

	def add_credit(self, credit, user):
		transaction = self._transaction(responsible = user, description = "BrmBar credit replenishment for " + user.name)
		self.cash.debit(transaction, credit, user.name)
		user.credit(transaction, credit, "Credit replenishment")
		self.db.commit()

	def _transaction(self, responsible = None, description = None):
		with closing(self.db.cursor()) as cur:
			cur.execute("INSERT INTO transactions (responsible, description) VALUES (%s, %s) RETURNING id",
					[responsible.id if responsible else None, description])
			transaction = cur.fetchone()[0]
		return transaction

	def credit_balance(self):
		with closing(self.db.cursor()) as cur:
			# We assume all debt accounts share a currency
			sumselect = """
				SELECT SUM(ts.amount)
					FROM accounts AS a
					LEFT JOIN transaction_splits AS ts ON a.id = ts.account
					WHERE a.acctype = %s AND ts.side = %s
			"""
			cur.execute(sumselect, ["debt", 'debit'])
			debit = cur.fetchone()[0] or 0
			cur.execute(sumselect, ["debt", 'credit'])
			credit = cur.fetchone()[0] or 0
		return debit - credit
	def credit_negbalance_str(self):
		return self.currency.str(-self.credit_balance())

	def inventory_balance(self):
		balance = 0
		with closing(self.db.cursor()) as cur:
			# Each inventory account has its own currency,
			# so we just do this ugly iteration
			cur.execute("SELECT id FROM accounts WHERE acctype = %s", ["inventory"])
			for inventory in cur:
				invid = inventory[0]
				inv = Account.load(self.db, id = invid)
				balance += inv.currency.convert(inv.balance(), self.currency)
		return balance
	def inventory_negbalance_str(self):
		return self.currency.str(-self.inventory_balance())
