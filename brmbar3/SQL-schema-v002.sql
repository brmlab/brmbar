-- intoduce implementation schema
CREATE SCHEMA IF NOT EXISTS brmbar_implementation;
-- version table (with initialization)
CREATE TABLE IF NOT EXISTS brmbar_implementation.brmbar_schema (
	ver INTEGER NOT NULL
);
DO $$
DECLARE v INTEGER;
BEGIN
	SELECT ver FROM brmbar_implementation.brmbar_schema INTO v;
	IF v IS NULL THEN
		INSERT INTO brmbar_implementation.brmbar_schema (ver) VALUES (1);
	END IF;
END;
$$;


--- upgrade schema
DO $$
DECLARE
current_ver INTEGER;
BEGIN

SELECT ver FROM brmbar_implementation.brmbar_schema INTO current_ver;
IF current_ver <> 1 THEN
	RAISE EXCEPTION 'BrmBar schema version % cannot be upgraded to version 2.', current_ver;
END IF;

ALTER TYPE public.account_type ADD VALUE 'trading';

--drop function if exists public.create_currency;
CREATE OR REPLACE PROCEDURE public.create_currency(
	IN i_name public.currencies.name%TYPE,
	OUT o_id public.currencies.id%TYPE)
LANGUAGE plpgsql SECURITY DEFINER AS $fn$
BEGIN
        INSERT INTO currencies ("name") VALUES (i_name) RETURNING o_id;
END
$fn$;

CREATE OR REPLACE PROCEDURE public.undo_transaction(
	IN i_id public.transactions.id%TYPE,
	OUT o_id public.transactions.id%TYPE)
LANGUAGE plpgsql SECURITY DEFINER AS $fn$
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
	o_id := v_ntrn_id;
END
$fn$;

-- this is for the case that psycopg2 cannot do output arguments
CREATE OR REPLACE FUNCTION public.undo_transaction_fn(
	IN i_id public.transactions.id%TYPE)
RETURNS public.transactions.id%TYPE
VOLATILE  NOT LEAKPROOF  LANGUAGE plpgsql AS $fn$
DECLARE
	v_ntrn_id public.transactions.id%TYPE;
BEGIN
	CALL public.undo_transaction(i_id, v_ntrn_id);
	RETURN v_ntrn_id;
END
$fn$;


-- end of upgrade do block
end
$$;

