--
-- 0020-shop-undo.sql
--
-- #20 - stored function for undo transaction
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

IF brmbar_privileged.has_exact_schema_version(19) THEN

CREATE OR REPLACE FUNCTION public.undo_transaction(
	IN i_id public.transactions.id%TYPE)
RETURNS public.transactions.id%TYPE
VOLATILE  NOT LEAKPROOF  LANGUAGE plpgsql AS $fn$
DECLARE
	v_ntrn_id public.transactions.id%TYPE;
	v_old_trn public.transactions%ROWTYPE;
	v_old_split public.transaction_splits%ROWTYPE;
BEGIN
	SELECT * INTO v_old_trn FROM public.transactions WHERE id = i_id;
        INSERT INTO transactions ("description") VALUES ('undo '||o_id||' ('||v_old_trn.description||')') RETURNING id into v_ntrn_id;
	FOR v_old_split IN
		SELECT * FROM transaction_splits WHERE "transaction" = i_id
	LOOP
		INSERT INTO transaction_splits ("transaction", "side", "account", "amount", "memo")
		VALUES (v_ntrn_id, v_old_split.side, v_old_split.account, -v_old_split.amount,
			'undo ' || v_old_split.id || ' (' || v_old_split.memo || ')' );
	END LOOP;
	RETURN v_ntrn_id;
END;
$fn$;



PERFORM brmbar_privileged.upgrade_schema_version_to(20);
END IF;

END;
$upgrade_block$;

-- vim: set ft=plsql :
