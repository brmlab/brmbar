
class Currency:
    """ Currency
    
    Each account has a currency (1 Kč, 1 Club Maté, ...), pairs of
    currencies have (asymmetric) exchange rates. """
    def __init__(self, db, id, name):
        self.db = db
        self.id = id
        self.name = name

    @classmethod
    def default(cls, db):
        """ Default wallet currency """
        return cls.load(db, name = "Kč")

    @classmethod
    def load(cls, db, id = None, name = None):
        """ Constructor for existing currency """
        if id is not None:
            name = db.execute_and_fetch("SELECT name FROM currencies WHERE id = %s", [id])
            name = name[0]
        elif name is not None:
            id = db.execute_and_fetch("SELECT id FROM currencies WHERE name = %s", [name])
            id = id[0]
        else:
            raise NameError("Currency.load(): Specify either id or name")
        return cls(db, name = name, id = id)

    @classmethod
    def create(cls, db, name):
        """ Constructor for new currency """
        id = db.execute_and_fetch("INSERT INTO currencies (name) VALUES (%s) RETURNING id", [name])
        id = id[0]
        return cls(db, name = name, id = id)

    def rates(self, other):
        """ Return tuple ($buy, $sell) of rates of $self in relation to $other (brmbar.Currency):
        $buy is the price of $self in means of $other when buying it (into brmbar)
        $sell is the price of $self in means of $other when selling it (from brmbar) """

        res = self.db.execute_and_fetch("SELECT rate, rate_dir FROM exchange_rates WHERE target = %s AND source = %s AND valid_since <= NOW() ORDER BY valid_since DESC LIMIT 1", [self.id, other.id])
        if res is None:
            raise NameError("Currency.rate(): Unknown conversion " + other.name() + " to " + self.name())
        buy_rate, buy_rate_dir = res
        buy = buy_rate if buy_rate_dir == "target_to_source" else 1/buy_rate

        res = self.db.execute_and_fetch("SELECT rate, rate_dir FROM exchange_rates WHERE target = %s AND source = %s AND valid_since <= NOW() ORDER BY valid_since DESC LIMIT 1", [other.id, self.id])
        if res is None:
            raise NameError("Currency.rate(): Unknown conversion " + self.name() + " to " + other.name())
        sell_rate, sell_rate_dir = res
        sell = sell_rate if sell_rate_dir == "source_to_target" else 1/sell_rate

        return (buy, sell)

    def convert(self, amount, target):
        res = self.db.execute_and_fetch("SELECT rate, rate_dir FROM exchange_rates WHERE target = %s AND source = %s AND valid_since <= NOW() ORDER BY valid_since DESC LIMIT 1", [target.id, self.id])
        if res is None:
            raise NameError("Currency.convert(): Unknown conversion " + self.name() + " to " + target.name())
        rate, rate_dir = res
        if rate_dir == "source_to_target":
            resamount = amount * rate
        else:
            resamount = amount / rate
        return resamount

    def str(self, amount):
        return "{:.2f} {}".format(amount, self.name)

    def update_sell_rate(self, target, rate):
        self.db.execute("INSERT INTO exchange_rates (source, target, rate, rate_dir) VALUES (%s, %s, %s, %s)", [self.id, target.id, rate, "source_to_target"])
    def update_buy_rate(self, source, rate):
        self.db.execute("INSERT INTO exchange_rates (source, target, rate, rate_dir) VALUES (%s, %s, %s, %s)", [source.id, self.id, rate, "target_to_source"])
