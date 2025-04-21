--
-- 0019-shop-consolidate.sql
--
-- #19 - stored function for "consolidation" transaction
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

IF brmbar_privileged.has_exact_schema_version(18) THEN

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

CREATE OR REPLACE FUNCTION public.make_consolidate_transaction(
	i_excess_id public.accounts.id%TYPE,
	i_deficit_id public.accounts.id%TYPE,
	i_profits_id public.accounts.id%TYPE
) RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
	v_transaction_id public.transactions.id%TYPE;
	v_excess_balance NUMERIC;
	v_deficit_balance NUMERIC;
	v_ret TEXT;
BEGIN
	v_ret := NULL;
	-- Create a new transaction
	v_transaction_id := brmbar_privileged.create_transaction(NULL,
		'BrmBar inventory consolidation');
	v_excess_balance := public.compute_account_balance(i_excess_id);
	v_deficit_balance := public.compute_account_balance(i_deficit_id);
	IF v_excess_balance <> 0 THEN
		v_ret := 'Excess balance ' || -v_excess_balance || ' debited to profit';
		INSERT INTO public.transaction_splits (transaction, side, account, amount, memo)
			VALUES (i_transaction_id, 'debit', i_excess_id, -v_excess_balance,
			'Excess balance added to profit.');
		INSERT INTO public.transaction_splits (transaction, side, account, amount, memo)
			VALUES (i_transaction_id, 'debit', i_profits_id, -v_excess_balance,
			'Excess balance added to profit.');
	END IF;
	IF v_deficit_balance <> 0 THEN
		v_ret := COALESCE(v_ret, '');
		v_ret := v_ret || 'Deficit balance ' || v_deficit_balance || ' credited to profit';
		INSERT INTO public.transaction_splits (transaction, side, account, amount, memo)
			VALUES (i_transaction_id, 'credit', i_deficit_id, v_deficit_balance,
			'Deficit balance removed from profit.');
		INSERT INTO public.transaction_splits (transaction, side, account, amount, memo)
			VALUES (i_transaction_id, 'credit', i_profits_id, v_deficit_balance,
			'Deficit balance removed from profit.');
	END IF;
	RETURN v_ret;
END;
$$;

PERFORM brmbar_privileged.upgrade_schema_version_to(19);
END IF;

END;
$upgrade_block$;

-- vim: set ft=plsql :
