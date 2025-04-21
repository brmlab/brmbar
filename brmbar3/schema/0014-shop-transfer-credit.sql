--
-- 0014-shop-transfer-credit.sql
--
-- #14 - stored function for "credit" transfer transactions
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

CREATE OR REPLACE FUNCTION public.transfer_credit(
	i_cash_account_id public.accounts.id%TYPE,
	i_credit NUMERIC,
	i_userfrom_id public.accounts.id%TYPE,
	i_userfrom_name TEXT,
	i_userto_id public.accounts.id%TYPE,
	i_userto_name TEXT
) RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM public.add_credit(i_cash_account_id, i_credit, i_userto_id, i_userto_name);
	PERFORM public.withdraw_credit(i_cash_account_id, i_credit, i_userfrom_id, i_userfrom_name);
END;
$$;



PERFORM brmbar_privileged.upgrade_schema_version_to(13);
END IF;

END;
$upgrade_block$;

-- vim: set ft=plsql :
