CREATE OR REPLACE FUNCTION accounts_id_seq_value()
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result bigint;
BEGIN
    SELECT last_value FROM accounts_id_seq
    INTO result;
    RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION transactions_id_seq_value()
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result bigint;
BEGIN
    SELECT last_value FROM transactions_id_seq
    INTO result;
    RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION transaction_splits_id_seq_value()
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result bigint;
BEGIN
    SELECT last_value FROM transaction_splits_id_seq
    INTO result;
    RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION currencies_id_seq_value()
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result bigint;
BEGIN
    SELECT last_value FROM currencies_id_seq
    INTO result;
    RETURN result;
END;
$$;


