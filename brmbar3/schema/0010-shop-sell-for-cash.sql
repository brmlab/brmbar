--
-- 0010-shop-sell-for-cash.sql
--
-- #10 - stored function for cash sell transaction
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

IF brmbar_privileged.has_exact_schema_version(9) THEN

CREATE OR REPLACE FUNCTION brmbar_privileged.create_transaction(
	i_responsible_id public.accounts.id%TYPE,
	i_description public.transactions.description%TYPE
) RETURNS public.transactions.id%TYPE AS $$
DECLARE
	new_transaction_id public.transactions.id%TYPE;
BEGIN
	-- Create a new transaction
	INSERT INTO public.transactions (responsible, description)
	VALUES (i_responsible_id, i_description)
	RETURNING id INTO new_transaction_id;
	-- Return the new transaction ID
	RETURN new_transaction_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION brmbar_privileged.sell_item_internal(
	i_item_id public.accounts.id%TYPE,
	i_amount INTEGER,
	i_user_id public.accounts.id%TYPE,
	i_target_currency_id public.currencies.id%TYPE,
	i_other_memo TEXT,
	i_description TEXT
) RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
	v_buy_rate NUMERIC;
	v_sell_rate NUMERIC;
	v_cost NUMERIC;
	v_profit NUMERIC;
	v_transaction_id public.transactions.id%TYPE;
BEGIN
	-- Get the buy and sell rates from the stored functions
	v_buy_rate := public.find_buy_rate(i_item_id, i_target_currency_id);
	v_sell_rate := public.find_sell_rate(i_item_id, i_target_currency_id);

	-- Calculate cost and profit
	v_cost := i_amount * v_sell_rate;
	v_profit := i_amount * (v_sell_rate - v_buy_rate);

	-- Create a new transaction
	v_transaction_id := brmbar_privileged.create_transaction(i_user_id, i_description);

	-- the item (decrease stock)
	INSERT INTO public.transaction_splits (transaction, side, account, amount, memo)
	VALUES (v_transaction_id, 'credit', i_item_id, i_amount,
	i_other_memo);

	-- the user
	INSERT INTO public.transaction_splits (transaction, side, account, amount, memo)
	VALUES (v_transaction_id, 'debit', i_user_id, v_cost,
	(SELECT "name" FROM public.accounts WHERE id = i_item_id));

	-- the profit
	INSERT INTO public.transaction_splits (transaction, side, account, amount, memo)
	VALUES (v_transaction_id, 'debit', (SELECT account_id FROM accounts WHERE name = 'BrmBar Profits'), v_profit, (SELECT 'Margin on ' || "name" FROM public.accounts WHERE id = i_item_id));

	-- Return the cost
	RETURN v_cost;
END;
$$;

CREATE OR REPLACE FUNCTION public.sell_item(
	i_item_id public.accounts.id%TYPE,
	i_amount INTEGER,
	i_user_id public.accounts.id%TYPE,
	i_target_currency_id public.currencies.id%TYPE,
	i_description TEXT
) RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN brmbar_privileged.sell_item_internal(i_item_id,
		i_amount,
		i_user_id,
		i_target_currency_id,
		(SELECT "name" FROM public.accounts WHERE id = i_user_id),
		i_description);
END;
$$;

CREATE OR REPLACE FUNCTION public.sell_item_for_cash(
	i_item_id public.accounts.id%TYPE,
	i_amount INTEGER,
	i_user_id public.accounts.id%TYPE,
	i_target_currency_id public.currencies.id%TYPE,
	i_description TEXT
) RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN brmbar_privileged.sell_item_internal(i_item_id,
		i_amount,
		i_user_id,
		i_target_currency_id,
		'Cash',
		i_description);
END;
$$;

DROP FUNCTION public.create_transaction;

PERFORM brmbar_privileged.upgrade_schema_version_to(10);
END IF;

END;
$upgrade_block$;

-- vim: set ft=plsql :
