from .Currency import Currency

class Account:
    """ BrmBar Account

    Both users and items are accounts. So is the money box, etc.
    Each account has a currency."""
    def __init__(self, db, id, name, currency, acctype):
        self.db = db
        self.id = id
        self.name = name
        self.currency = currency
        self.acctype = acctype

    @classmethod
    def load_by_barcode(cls, db, barcode):
        res = db.execute_and_fetch("SELECT account FROM barcodes WHERE barcode = %s", [barcode])
        if res is None:
            return None
        id = res[0]
        return cls.load(db, id = id)

    @classmethod
    def load(cls, db, id = None, name = None):
        """ Constructor for existing account """
        if id is not None:
            name = db.execute_and_fetch("SELECT name FROM accounts WHERE id = %s", [id])
            name = name[0]
        elif name is not None:
            id = db.execute_and_fetch("SELECT id FROM accounts WHERE name = %s", [name])
            id = id[0]
        else:
            raise NameError("Account.load(): Specify either id or name")

        currid, acctype = db.execute_and_fetch("SELECT currency, acctype FROM accounts WHERE id = %s", [id])
        currency = Currency.load(db, id = currid)

        return cls(db, name = name, id = id, currency = currency, acctype = acctype)

    @classmethod
    def create(cls, db, name, currency, acctype):
        """ Constructor for new account """
        id = db.execute_and_fetch("INSERT INTO accounts (name, currency, acctype) VALUES (%s, %s, %s) RETURNING id", [name, currency.id, acctype])
        id = id[0]
        return cls(db, name = name, id = id, currency = currency, acctype = acctype)

    def balance(self):
        debit = self.db.execute_and_fetch("SELECT SUM(amount) FROM transaction_splits WHERE account = %s AND side = %s", [self.id, 'debit'])
        debit = debit[0] or 0
        credit = self.db.execute_and_fetch("SELECT SUM(amount) FROM transaction_splits WHERE account = %s AND side = %s", [self.id, 'credit'])
        credit = credit[0] or 0
        return debit - credit

    def balance_str(self):
        return self.currency.str(self.balance())

    def negbalance_str(self):
        return self.currency.str(-self.balance())

    def debit(self, transaction, amount, memo):
        return self._transaction_split(transaction, 'debit', amount, memo)

    def credit(self, transaction, amount, memo):
        return self._transaction_split(transaction, 'credit', amount, memo)

    def _transaction_split(self, transaction, side, amount, memo):
        """ Common part of credit() and debit(). """
        self.db.execute("INSERT INTO transaction_splits (transaction, side, account, amount, memo) VALUES (%s, %s, %s, %s, %s)", [transaction, side, self.id, amount, memo])

    def add_barcode(self, barcode):
        self.db.execute("INSERT INTO barcodes (account, barcode) VALUES (%s, %s)", [self.id, barcode])
        self.db.commit()

    def rename(self, name):
        self.db.execute("UPDATE accounts SET name = %s WHERE id = %s", [name, self.id])
        self.name = name
