import brmbar
from .Currency import Currency
from .Account import Account

class Shop:
    """ BrmBar Shop

    Business logic so that only interaction is left in the hands
    of the frontend scripts. """
    def __init__(self, db, currency, profits, cash, excess, deficit):
        self.db = db
        self.currency = currency # brmbar.Currency
        self.profits = profits # income brmbar.Account for brmbar profit margins on items
        self.cash = cash # our operational ("wallet") cash account
        self.excess = excess # account from which is deducted cash during inventory item fixing (when system contains less items than is the reality)
        self.deficit = deficit # account where is put cash during inventory item fixing (when system contains more items than is the reality)

    @classmethod
    def new_with_defaults(cls, db):
        return cls(db,
            currency = Currency.default(db),
            profits = Account.load(db, name = "BrmBar Profits"),
            cash = Account.load(db, name = "BrmBar Cash"),
            excess = Account.load(db, name = "BrmBar Excess"),
            deficit = Account.load(db, name = "BrmBar Deficit"))

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

    def undo_sale(self, item, user, amount = 1):
        # Undo sale; rarely needed
        (buy, sell) = item.currency.rates(self.currency)
        cost = amount * sell
        profit = amount * (sell - buy)

        transaction = self._transaction(responsible = user, description = "BrmBar sale UNDO of {}x {} to {}".format(amount, item.name, user.name))
        item.debit(transaction, amount, user.name + " (sale undo)")
        user.credit(transaction, cost, item.name + " (sale undo)")
        self.profits.credit(transaction, profit, "Margin repaid on " + item.name)
        self.db.commit()

        return cost

    def add_credit(self, credit, user):
        transaction = self._transaction(responsible = user, description = "BrmBar credit replenishment for " + user.name)
        self.cash.debit(transaction, credit, user.name)
        user.credit(transaction, credit, "Credit replenishment")
        self.db.commit()

    def withdraw_credit(self, credit, user):
        transaction = self._transaction(responsible = user, description = "BrmBar credit withdrawal for " + user.name)
        self.cash.credit(transaction, credit, user.name)
        user.debit(transaction, credit, "Credit withdrawal")
        self.db.commit()

    def buy_for_cash(self, item, amount = 1):
        # Buy: Currency conversion from item currency to shop currency
        (buy, sell) = item.currency.rates(self.currency)
        cost = amount * buy

        transaction = self._transaction(description = "BrmBar stock replenishment of {}x {} for cash".format(amount, item.name))
        item.debit(transaction, amount, "Cash")
        self.cash.credit(transaction, cost, item.name)
        self.db.commit()

        return cost

    def receipt_to_credit(self, user, credit, description):
        transaction = self._transaction(responsible = user, description = "Receipt: " + description)
        self.profits.credit(transaction, credit, user.name)
        user.credit(transaction, credit, "Credit from receipt: " + description)
        self.db.commit()

    def _transaction(self, responsible = None, description = None):
        transaction = self.db.execute_and_fetch("INSERT INTO transactions (responsible, description) VALUES (%s, %s) RETURNING id",
                [responsible.id if responsible else None, description])
        transaction = transaction[0]
        return transaction

    def credit_balance(self):
        # We assume all debt accounts share a currency
        sumselect = """
            SELECT SUM(ts.amount)
                FROM accounts AS a
                LEFT JOIN transaction_splits AS ts ON a.id = ts.account
                WHERE a.acctype = %s AND ts.side = %s
        """
        cur = self.db.execute_and_fetch(sumselect, ["debt", 'debit'])
        debit = cur[0] or 0
        credit = self.db.execute_and_fetch(sumselect, ["debt", 'credit'])
        credit = credit[0] or 0
        return debit - credit
    def credit_negbalance_str(self):
        return self.currency.str(-self.credit_balance())

    def inventory_balance(self):
        balance = 0
        # Each inventory account has its own currency,
        # so we just do this ugly iteration
        cur = self.db.execute_and_fetchall("SELECT id FROM accounts WHERE acctype = %s", ["inventory"])
        for inventory in cur:
            invid = inventory[0]
            inv = Account.load(self.db, id = invid)
            # FIXME: This is not correct as each instance of inventory
            # might have been bought for a different price! Therefore,
            # we need to replace the command below with a complex SQL
            # statement that will... ugh, accounting is hard!
            balance += inv.currency.convert(inv.balance(), self.currency)
        return balance
    def inventory_balance_str(self):
        return self.currency.str(self.inventory_balance())

    def account_list(self, acctype, like_str="%%"):
        """list all accounts (people or items, as per acctype)"""
        accts = []
        cur = self.db.execute_and_fetchall("SELECT id FROM accounts WHERE acctype = %s AND name ILIKE %s ORDER BY name ASC", [acctype, like_str])
		#FIXME: sanitize input like_str ^
        for inventory in cur:
            accts += [ Account.load(self.db, id = inventory[0]) ]
        return accts

    def fix_inventory(self, item, amount):
        amount_in_reality = amount
        amount_in_system = item.balance()
        (buy, sell) = item.currency.rates(self.currency)

        diff = abs(amount_in_reality - amount_in_system)
        buy_total = buy * diff
        if amount_in_reality > amount_in_system:
            transaction = self._transaction(description = "BrmBar inventory fix of {}pcs {} in system to {}pcs in reality".format(amount_in_system, item.name,amount_in_reality))
            item.debit(transaction, diff, "Inventory fix excess")
            self.excess.credit(transaction, buy_total, "Inventory fix excess " + item.name)
            self.db.commit()
            return True
        elif amount_in_reality < amount_in_system:
            transaction = self._transaction(description = "BrmBar inventory fix of {}pcs {} in system to {}pcs in reality".format(amount_in_system, item.name,amount_in_reality))
            item.credit(transaction, diff, "Inventory fix deficit")
            self.deficit.debit(transaction, buy_total, "Inventory fix deficit " + item.name)
            self.db.commit()
            return True
        else:
            return False
    def fix_cash(self, amount):
        amount_in_reality = amount
        amount_in_system = self.cash.balance()

        diff = abs(amount_in_reality - amount_in_system)
        if amount_in_reality > amount_in_system:
            transaction = self._transaction(description = "BrmBar cash inventory fix of {} in system to {} in reality".format(amount_in_system, amount_in_reality))
            self.cash.debit(transaction, diff, "Inventory fix excess")
            self.excess.credit(transaction, diff, "Inventory cash fix excess.")
            self.db.commit()
            return True
        elif amount_in_reality < amount_in_system:
            transaction = self._transaction(description = "BrmBar cash inventory fix of {} in system to {} in reality".format(amount_in_system, amount_in_reality))
            self.cash.credit(transaction, diff, "Inventory fix deficit")
            self.deficit.debit(transaction, diff, "Inventory fix deficit.")
            self.db.commit()
            return True
        else:
            return False