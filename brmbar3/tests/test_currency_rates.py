# tests/test_currency_rates.py
import pytest
from contextlib import closing
import math
from decimal import Decimal

# Assuming brmbar modules are importable via PYTHONPATH or package structure
from brmbar.Database import Database
from brmbar.Currency import Currency

# --- Fixtures ---

@pytest.fixture(scope="module")
def db_connection():
    """Provides a database connection for the test module."""
    # Ensure dbname is correct for your test environment
    # This connects using the default user/db setup expected by the entrypoint
    db = Database("dbname=brmbar")
    yield db
    # Explicitly close the connection if Database doesn't handle it
    if hasattr(db, 'db_conn') and db.db_conn and not db.db_conn.closed:
         db.db_conn.close()

@pytest.fixture(scope="module")
def all_currencies(db_connection):
    """Fetches all currency objects from the database."""
    # Ensure the connection is open before using it
    if not db_connection or not hasattr(db_connection, 'db_conn') or db_connection.db_conn.closed:
        pytest.skip("Database connection not available for fetching currencies") # Skip if DB setup failed

    currencies_data = []
    try:
        with closing(db_connection.db_conn.cursor()) as cur:
            # Added ORDER BY for consistent test order and reliable pairing
            cur.execute("SELECT id, name FROM currencies ORDER BY id")
            currencies_data = cur.fetchall()
    except Exception as e:
         pytest.fail(f"Failed to fetch currencies from DB: {e}")

    if not currencies_data:
        pytest.skip("No currencies found in the database to test")

    # Ensure db_connection is passed correctly to Currency constructor
    return [Currency(db_connection, id, name) for id, name in currencies_data]


# --- Test Function ---

# Helper to run a rate function and capture result or exception
def get_rate_or_exception(currency_from, currency_to, method_name):
    method = getattr(currency_from, method_name)
    try:
        # Ensure currency_to is passed to the method
        return method(currency_to), None
    except (RuntimeError, NameError) as e: # Add other expected exceptions if any
        return None, e
    except Exception as e: # Catch unexpected exceptions during rate calculation
        pytest.fail(f"Unexpected exception in {method_name} for {currency_from.name}->{currency_to.name}: {type(e).__name__}: {e}")


def test_rate_comparison(all_currencies):
    """Compares the results of rates() and rates2() for all currency pairs."""

    if not all_currencies:
        pytest.skip("Skipping test as no currencies were fetched.")

    # Iterate through all pairs of currencies
    for c1 in all_currencies:
        for c2 in all_currencies:
            # Ensure c1 and c2 are actual Currency objects (good practice, though should be true)
            assert isinstance(c1, Currency), f"Param c1 is not a Currency object: {c1}"
            assert isinstance(c2, Currency), f"Param c2 is not a Currency object: {c2}"

            rates1, exc1 = get_rate_or_exception(c1, c2, 'rates')
            rates2, exc2 = get_rate_or_exception(c1, c2, 'rates2')

            if exc1 or exc2:
                # If one raised an exception, the other must raise the *same* type and message
                assert exc1 is not None and exc2 is not None, \
                    f"Mismatch in exceptions for {c1.name}->{c2.name}. rates(): {exc1}, rates2(): {exc2}"
                assert type(exc1) == type(exc2), \
                    f"Exception type mismatch for {c1.name}->{c2.name}: {type(exc1).__name__} vs {type(exc2).__name__}"
                assert str(exc1) == str(exc2), \
                    f"Exception message mismatch for {c1.name}->{c2.name}: '{exc1}' vs '{exc2}'"
                # If exceptions match, the test passes for this pair
            else:
                # If neither raised an exception, compare rates using pytest.approx
                assert rates1 is not None and rates2 is not None, \
                     f"Expected rates but got None (and no exception) for {c1.name}->{c2.name}"

                # Check if rates are tuples of two numbers (buy, sell)
                assert isinstance(rates1, tuple) and len(rates1) == 2, f"rates() result not a tuple(buy, sell) for {c1.name}->{c2.name}: {rates1}"
                assert isinstance(rates2, tuple) and len(rates2) == 2, f"rates2() result not a tuple(buy, sell) for {c1.name}->{c2.name}: {rates2}"
                assert all(isinstance(r, (int, float, Decimal)) for r in rates1), f"rates() values not numeric for {c1.name}->{c2.name}: {rates1}"
                assert all(isinstance(r, (int, float, Decimal)) for r in rates2), f"rates2() values not numeric for {c1.name}->{c2.name}: {rates2}"

                # Compare buy and sell rates approximately
                # Use rel= or abs= if default tolerance is not suitable
                assert rates1[0] == pytest.approx(rates2[0]), \
                    f"Buy rate mismatch for {c1.name}->{c2.name}: {rates1[0]} vs {rates2[0]}"
                assert rates1[1] == pytest.approx(rates2[1]), \
                    f"Sell rate mismatch for {c1.name}->{c2.name}: {rates1[1]} vs {rates2[1]}"