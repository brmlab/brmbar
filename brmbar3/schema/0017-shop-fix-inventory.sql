--
-- 0017-shop-fix-inventory.sql
--
-- #17 - stored function for "fixing" inventory transaction
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

IF brmbar_privileged.has_exact_schema_version(16) THEN

CREATE OR REPLACE FUNCTION public.compute_account_balance(
	i_account_id public.accounts.id%TYPE
) RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
	v_crsum NUMERIC;
	v_dbsum NUMERIC;
BEGIN
	SELECT COALESCE(SUM(CASE WHEN side='credit' THEN amount ELSE 0 END),0) crsum INTO v_crsum,
	COALESCE(SUM(CASE WHEN side='debit' THEN amount ELSE 0 END),0) dbsum into v_dbsum
	FROM public.transaction_splits ts WHERE ts.account=4
	RETURN v_dbsum - v_crsum;
END; $$;

CREATE OR REPLACE FUNCTION brmbar_privileged.fix_account_balance(
	IN i_account_id public.acounts.id%TYPE,
	IN i_account_currency_id public.currencies.id%TYPE,
	IN i_excess_id public.acounts.id%TYPE,
	IN i_deficit_id public.acounts.id%TYPE,
	IN i_shop_currency_id public.currencies.id%TYPE,
	IN i_amount_in_reality NUMERIC
) RETURNS BOOLEAN
VOLATILE  NOT LEAKPROOF  LANGUAGE plpgsql AS $fn$
DECLARE
	v_amount_in_system NUMERIC;
	v_buy_rate NUMERIC;
	v_currency_id public.currencies.id%TYPE;
	v_diff NUMERIC;
	v_buy_total NUMERIC;
	v_ntrn_id public.transactions.id%TYPE;
	v_transaction_memo TEXT;
	v_item_name TEXT;
	v_excess_memo TEXT;
	v_deficit_memo TEXT;

	v_old_trn public.transactions%ROWTYPE;
	v_old_split public.transaction_splits%ROWTYPE;
BEGIN
	v_amount_in_system := public.compute_account_balance(i_account_id);
	IF i_account_currency_id <> i_shop_currency_id THEN
		v_buy_rate := public.find_buy_rate(i_item_id, i_shop_currency_id);
	ELSE
		v_buy_rate := 1;
	END IF;

	v_diff := ABS(i_amount_in_reality - v_amount_in_system);
	v_buy_total := v_buy_rate * v_diff;
	-- compute memo strings
	IF i_item_id = 1 THEN -- cash account recognized by magic id
		-- fixing cash
		v_transaction_memo :=
		'BrmBar cash inventory fix of ' || v_amount_in_system
		|| ' in system to ' || i_amount_in_reality || ' in reality';
		v_excess_memo := 'Inventory cash fix excess.';
		v_deficit_memo := 'Inventory fix deficit.';
	ELSE
		-- fixing other account
		SELECT "name" INTO v_item_name FROM public.accounts WHERE id = i_account_id;
		v_transaction_memo :=
		'BrmBar inventory fix of ' || v_amount_in_system || 'pcs '
		|| v_item_name
		|| ' in system to ' || i_amount_in_reality || 'pcs in reality';
		v_excess_memo := 'Inventory fix excess ' || v_item_name;
		v_deficit_memo := 'Inventory fix deficit ' || v_item_name;
	END IF;
	-- create transaction based on the relation between counting and accounting
	IF i_amount_in_reality > v_amount_in_system THEN
		v_ntrn_id := brmbar_privileged.create_transaction(NULL, v_transaction_memo);
		INSERT INTO transaction_splits ("transaction", "side", "account", "amount", "memo")
		VALUES (v_ntrn_id, 'debit', i_item_id, v_diff, 'Inventory fix excess');
		INSERT INTO transaction_splits ("transaction", "side", "account", "amount", "memo")
		VALUES (v_ntrn_id, 'credit', i_excess_id, v_buy_total, v_excess_memo);
		RETURN TRUE;
	ELSIF i_amount_in_reality < v_amount_in_system THEN
		v_ntrn_id := brmbar_privileged.create_transaction(NULL, v_transaction_memo);
		INSERT INTO transaction_splits ("transaction", "side", "account", "amount", "memo")
		VALUES (v_ntrn_id, 'credit', i_item_id, v_diff, 'Inventory fix deficit');
		INSERT INTO transaction_splits ("transaction", "side", "account", "amount", "memo")
		VALUES (v_ntrn_id, 'debit', i_deficit_id, v_buy_total, v_deficit_memo);
		RETURN TRUE;
	ELSIF i_account_id <> 1 THEN -- cash account recognized by magic id
		-- record that everything is going on swimmingly only for noncash accounts (WTF)
		v_ntrn_id := brmbar_privileged.create_transaction(NULL, v_transaction_memo);
		INSERT INTO transaction_splits ("transaction", "side", "account", "amount", "memo")
		VALUES (v_ntrn_id, 'debit', i_item_id, 0, 'Inventory fix - amount was correct');
		INSERT INTO transaction_splits ("transaction", "side", "account", "amount", "memo")
		VALUES (v_ntrn_id, 'credit', i_item_id, 0, 'Inventory fix - amount was correct');
		RETURN FALSE;
	END IF;
	RETURN FALSE;
END;
$fn$;


CREATE OR REPLACE FUNCTION public.fix_inventory(
	IN i_account_id public.acounts.id%TYPE,
	IN i_account_currency_id public.currencies.id%TYPE,
	IN i_excess_id public.acounts.id%TYPE,
	IN i_deficit_id public.acounts.id%TYPE,
	IN i_shop_currency_id public.currencies.id%TYPE,
	IN i_amount_in_reality NUMERIC
) RETURNS BOOLEAN
VOLATILE  NOT LEAKPROOF  LANGUAGE plpgsql AS $fn$
BEGIN
	RETURN brmbar_privileged.fix_account_balance(
		i_account_id,
		i_account_currency_id,
		i_excess_id,
		i_deficit_id,
		i_shop_currency_id,
		i_amount_in_reality
	);
END;
$fn$;


PERFORM brmbar_privileged.upgrade_schema_version_to(17);
END IF;

END;
$upgrade_block$;

-- vim: set ft=plsql :
