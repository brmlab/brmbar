--
-- 0013-shop-withdraw-credit.sql
--
-- #13 - stored function for cash withdrawal transactions
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

IF brmbar_privileged.has_exact_schema_version(12) THEN

CREATE OR REPLACE FUNCTION public.withdraw_credit(
	i_cash_account_id public.accounts.id%TYPE,
	i_credit NUMERIC,
	i_user_id public.accounts.id%TYPE,
	i_user_name TEXT
) RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
	v_transaction_id public.transactions.id%TYPE;
BEGIN
	-- Create a new transaction
	v_transaction_id := brmbar_privileged.create_transaction(i_user_id, 'BrmBar credit withdrawal for ' || i_user_name);
	-- Debit cash (credit replenishment)
	INSERT INTO public.transaction_splits (transaction, side, account, amount, memo)
	VALUES (v_transaction_id, 'credit', i_cash_account_id, i_credit, i_user_name);
	-- Credit the user
	INSERT INTO public.transaction_splits (transaction, side, account, amount, memo)
	VALUES (v_transaction_id, 'debit', i_user_id, i_credit, 'Credit withdrawal');
END;
$$;



PERFORM brmbar_privileged.upgrade_schema_version_to(13);
END IF;

END;
$upgrade_block$;

-- vim: set ft=plsql :
