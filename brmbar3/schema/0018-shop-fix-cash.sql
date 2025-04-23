--
-- 0018-shop-fix-cash.sql
--
-- #18 - stored function for "fixing cash" transaction
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

IF brmbar_privileged.has_exact_schema_version(17) THEN

CREATE OR REPLACE FUNCTION public.fix_cash(
	IN i_excess_id public.accounts.id%TYPE,
	IN i_deficit_id public.accounts.id%TYPE,
	IN i_shop_currency_id public.currencies.id%TYPE,
	IN i_amount_in_reality NUMERIC
) RETURNS BOOLEAN
VOLATILE  NOT LEAKPROOF  LANGUAGE plpgsql AS $fn$
BEGIN
	RETURN brmbar_privileged.fix_account_balance(
		1,
		1,
		i_excess_id,
		i_deficit_id,
		i_shop_currency_id,
		i_amount_in_reality
	);
END;
$fn$;


PERFORM brmbar_privileged.upgrade_schema_version_to(18);
END IF;

END;
$upgrade_block$;

-- vim: set ft=plsql :
