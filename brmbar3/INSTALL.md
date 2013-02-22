BrmBar v3 Installation
======================

This is woefully incomplete; if you are deploying BrmBar, at this
point you will likely need to learn at least something aobut its
structure and internals. Some code modifications might even be
required too. Patches enhancing user configurability are welcome!

Maybe some things are missing. Ask the developers if you get in trouble,
e.g. in #brmlab on FreeNode.

Hardware Requirements
---------------------

* Display. Current UI is optimized for 4:3, 1024x768 display.
* Touchscreen. In emergency, you can use a mouse too, but it's
  clumsy and scrolling is not too intuitive.
* Barcode reader. We want the kind that will behave as a HID device
  and on scanning a barcode, it will send a CR-terminated scanned string.
* Physical keyboard stashed in vicinity will help. It is possible
  to enter text (inventory names, receipt reasons) on the touchscreen,
  but it's a bit frustrating.
* You will want to print a sheet of barcodes with names of all user
  accounts; these will be then used by people to buy stuff using their
  accounts - first scan barcode of the item, then scan your barcode,
  voila. Scanning your barcode directly can bring the user to a screen
  where they can see their credit and charge it too. See also USAGE.

Software Requirements
---------------------

* Developed and tested on Debian, but should work on other systems too.
* Python 3.
* QT4 with Python bindings:
  * QT4 with the "Declarative" module, e.g. libqt4-declarative package.
  * The PySide Qt4 bindings, e.g. python3-pyside.qtdeclarative package.
  * Installing the qtcreator program may be helpful for QML testing
    and development.
* PostgreSQL with Python pindings:
  * The database server itself, e.g. postgresql package.
  * PsyCoPg2, e.g. python3-psycopg2 package.

Software Setup
--------------

* Create psql user and `brmbar` database.

    brmuser@host:~> su postgres
    postgres@host:/home/user> createuser -D brmuser
    postgres@host:/home/user> su brmuser
    brmuser@host:~> createdb brmbar

* The SQL schema in file `SQL` contains the required SQL tables,
  but also INSERTs that add some rows essential for proper operation;
  base currency and two base accounts.  You *will* want to tweak the
  currency name; default is `Kč` (the Czech crown), replace it with
  your currency symbol. Then do `git grep 'Kč'` and replace all other
  occurences of `Kč` in brmbar source with your currency name.
* Load the SQL schema stored in file `SQL` in the database.

    brmuser@host:~/brmbar/brmbar3> psql brmbar
    psql (9.1.8)
	Type "help" for help.

	brmbar=# \i SQL

* You should be able to fire up the GUI now and start entering data.
  If you want to make sure all works as expected, execute the SQL
  statements in file `SQL.test` (revisit for currency names too) which
  will populate the database with a bit of sample data for testing.
* Regarding adding users at this point and for other usage instructions,
  refer to the USAGE file.

TODO: Mention the actual commands to execute.

Troubleshooting
---------------

Assuming that you run brmbar from a terminal, if something gets
stuck, you can switch to the terminal by Alt-TAB, then kill brmbar
by the Ctrl-\ shortcut (sends SIGQUIT) and restart it.
