--RESET search_path;
SELECT pg_catalog.set_config('search_path', '', false);
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

CREATE OR REPLACE FUNCTION brmbar_implementation.has_exact_schema_version(
	IN i_ver INTEGER NOT NULL
) RETURNS INTEGER
VOLATILE  NOT LEAKPROOF  LANGUAGE plpgsql AS $$
DECLARE
	v_ver INTEGER;
BEGIN
	SELECT ver INTO STRICT v_ver FROM brmbar_implementation.brmbar_schema;
	IF v_ver IS NULL or v_ver <> i_ver THEN
		RAISE EXCEPTION 'Invalid brmbar schema version';
	END IF;
	RETURN v_ver;
/*
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE EXCEPTION 'PID % not found';
	WHEN TOO_MANY_ROWS THEN
		RAISE EXCEPTION 'PID % not unique';
*/
END;
$$;

CREATE OR REPLACE FUNCTION brmbar_implementation.upgrade_schema_version_to(
	IN i_ver INTEGER NOT NULL
) RETURNS INTEGER
VOLATILE  NOT LEAKPROOF  LANGUAGE plpgsql AS $$
DECLARE
	v_ver INTEGER;
BEGIN
	SELECT brmbar_implementation.has_exact_schema_version(i_ver) INTO v_ver;
	IF v_ver + 1 = i_ver THEN
		UPDATE brmbar_implementation.brmbar_schema SET ver = i_ver;
	ELSE
		RAISE EXCEPTION 'Invalid brmbar schema version';
	END IF;
	RETURN i_ver;
END;
$$;

-- vim: set ft=plsql :

