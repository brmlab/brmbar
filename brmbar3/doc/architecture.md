BrmBar v3 - Architectural Overview
==================================

BrmBar v3 is written in Python, with the database stored in PostgreSQL
and the primary user interface modelled in QtQuick. All user interfaces
share a common *brmbar* package that provides few Python classes for
manipulation with the base objects.

Objects and Database Schema
---------------------------

### Account ###

The most essential brmbar object is an Account, which can track
balances of various kinds (described by *acctype* column) in the
classical accounting paradigm:

* **Cash**: A physical stash of cash. One cash account is created
  by default, corresponding to the cash box where people put money
  when buying stuff (or depositing money in their user accounts).
  Often, that's the only cash account you need.
* **Debt**: Represents brmbar's debt to some person. These accounts
  are actually the "user accounts" where people deposit money. When
  a deposit of 100 is made, 100 is *subtracted* from the balance,
  the balance is -100 and brmbar is in debt of 100 to the user.
  When the user buys something for 200, 200 is *added* to the balance,
  the balance is 100 and the user is in debt of 100 to the brmbar.
  This is correct notation from accounting point of view, but somewhat
  confusing for the users, so in the user interface (and crbalance
  column of some views), this balance is *negated*!
* **Inventory**: Represents inventory items (e.g. Club Mate bottles).
  The account balance represents the quantity of items.
* **Income**: Represents pure income of brmbar, i.e. the profit;
  there is usually just a single account of this type where all the
  profit (sell price of an item minus the buy price of an item)
  is accumulated.
* **Expense**: This type is currently not used.
* **Starting balance** and **ending balance**: This may be used
  in the future when transaction book needs to be compressed.

As you can see, the amount of cash, user accounts, inventory items
etc. are all represented as **Account** objects that are of various
**types**, are **named** and have a certain balance (calculated
from a transaction book). That balance is a number represented
in certain **currency**. It also has a set of **barcodes** associated.

### Currency, Exchange rate ###

Usually, all accounts that deal with cash (the cash, debt, income, ...
accounts) share a single currency that corresponds to the physical
currency locally in use (the default is `Kč`). However, inventory
items have balances corresponding to item quantities - to deal with
this correctly, each inventory item *has its own currency*; i.e.
`Club Mate` bottle is a currency associated with the `Club Mate`
account.

Currencies have defined (uni-directional) exchange rates. The exchange
rate of "Kč to Club Mate bottles" is the buy price of Club Mate, how
much you pay for one bottle of Club Mate from the cash box when you
are stocking in Club Mate. The exchange rate of "Club Mate bottle to Kč"
is the sell price of Club Mate, how much you pay for one bottle of Club
Mate to the cash box when you are buying it from brmbar (sell price
should be higher than buy price if you want to make a profit).

Exchange rate is valid since some defined time; historical exchange
rates are therefore kept and this allows to account for changing prices
of inventory items. (Unfortunately, at the time of writing this, the
profit calculation actually didn't make use of that yet.)

### Transactions, Transaction splits ###

A transaction book is used to determine current account balances and
stores all operations related to accounts - depositing or withdrawing
money, stocking in items, and most importantly buying stuff (either for
cash or from a debt account). A transaction happenned at some **time**
and was performed by certain **responsible** person.

The actual accounts involved in a transaction are specified by a list of
transaction splits that either put balance into the transaction (*credit*
side) or grab balance from it (*debit* side). For example, a typical
transaction representing a sale of Club Mate bottle to user "pasky"
would be split like this:

* *credit* of 1 Club Mate on Club Mate account with memo "pasky".
* *debit* of 35 Kč on "pasky" account with memo "Club Mate"
  (indeed we _add_ 35Kč to the debt account for pasky buying
  the Club Mate; if this seems weird, refer to the "debt" account
  type description).
* *debit* of 5 Kč on income account Profits with memo "Margin
  on Club Mate" (this represents the sale price - buy price delta,
  i.e. the profit we made in brmbar by selling this Club Mate).

The brmbar Python Package
-------------------------

The **brmbar** package (in brmbar/ subdirectory) provides common brmbar
functionality for the various user interfaces:

* **Database**: Layer for performing SQL queries with some error handling.
* **Currency**: Class for querying and manipulating currency objects and
  converting between them based on stored exchange rates.
* **Account**: Class for querying and manipulating the account objects
  and their current balance.
* **Shop**: Class providing the "business logic" of all the actual user
  operations: selling stuff, depositing and withdrawing moeny, adding
  stock, retrieving list of accounts of given type, etc.
