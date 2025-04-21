--
-- 0016-shop-buy-for-cash.sql
--
-- #16 - stored function for receipt reimbursement transaction
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

CREATE OR REPLACE FUNCTION public.receipt_reimbursement(
	i_profits_id public.accounts.id%TYPE,
	i_user_id public.accounts.id%TYPE,
	i_user_name public.accounts.name%TYPE,
	i_amount NUMERIC,
	i_description TEXT
) RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
	v_transaction_id public.transactions.id%TYPE;
BEGIN
	-- Create a new transaction
	v_transaction_id := brmbar_privileged.create_transaction(i_user_id,
		'Receipt: ' || i_description);
	-- the "profit"
	INSERT INTO public.transaction_splits (transaction, side, account, amount, memo)
	VALUES (i_transaction_id, 'credit', i_profits_id, i_amount, i_user_name);
	-- the user
	INSERT INTO public.transaction_splits (transaction, side, account, amount, memo)
	VALUES (i_transaction_id, 'credit', i_user_id, i_amount, 'Credit from receipt: ' || i_description);
END;
$$;

PERFORM brmbar_privileged.upgrade_schema_version_to(10);
END IF;

END;
$upgrade_block$;

-- vim: set ft=plsql :
