--
-- 0015-shop-buy-for-cash.sql
--
-- #15 - stored function for cash-based stock replenishment transaction
--
-- ISC License
--
-- Copyright 2023-2025 Brmlab, z.s.
-- TMA <tma+hs@jikos.cz>
--
-- Permission to use, copy, modify, and/or distribute this software
-- for any purpose with or without fee is hereby granted, provided
-- that the above copyright notice and this permission notice appear
-- in all copies.
--
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
-- WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
-- AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
-- CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
-- OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
-- NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
-- CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
--

-- To require fully-qualified names
SELECT pg_catalog.set_config('search_path', '', false);

DO $upgrade_block$
BEGIN

IF brmbar_privileged.has_exact_schema_version(14) THEN

CREATE OR REPLACE FUNCTION public.buy_for_cash(
	i_cash_account_id public.accounts.id%TYPE,
	i_item_id public.accounts.id%TYPE,
	i_amount INTEGER,
	i_target_currency_id public.currencies.id%TYPE,
	i_item_name TEXT
) RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
	v_buy_rate NUMERIC;
	v_cost NUMERIC;
	v_transaction_id public.transactions.id%TYPE;
BEGIN
	-- this could fail and it would generate exception in python
	-- FIXME: convert v_buy_rate < 0 into python exception
	v_buy_rate := public.find_buy_rate(i_item_id, i_target_currency_id);
	-- this could fail and it would generate exception in python, even though it is not used
	--v_sell_rate := public.find_sell_rate(i_item_id, i_target_currency_id);

	-- Calculate cost and profit
	v_cost := i_amount * v_buy_rate;

	-- Create a new transaction
	v_transaction_id := brmbar_privileged.create_transaction(NULL,
		'BrmBar stock replenishment of ' || i_amount || 'x ' || i_item_name || ' for cash');

	-- the item
	INSERT INTO public.transaction_splits (transaction, side, account, amount, memo)
	VALUES (i_transaction_id, 'debit', i_item_id, i_amount,
	'Cash');

	-- the cash
	INSERT INTO public.transaction_splits (transaction, side, account, amount, memo)
	VALUES (i_transaction_id, 'credit', i_cash_account_id, v_cost,
	i_item_name);

	-- Return the cost
	RETURN v_cost;
END;
$$;

PERFORM brmbar_privileged.upgrade_schema_version_to(15);
END IF;

END;
$upgrade_block$;

-- vim: set ft=plsql :
