--
-- 0001-init.sql
--
-- Initial SQL schema construction as of 2025-04-20 (or so)
--
-- ISC License
--
-- Copyright 2023-2025 Brmlab, z.s.
-- Dominik Pantůček <dominik.pantucek@trustica.cz>
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

-- Privileged schema with protected data
CREATE SCHEMA IF NOT EXISTS brmbar_privileged;

-- Initial versioning
CREATE TABLE IF NOT EXISTS brmbar_privileged.brmbar_schema(
  ver INTEGER NOT NULL
);

-- ----------------------------------------------------------------
-- Legacy Schema Initialization
-- ----------------------------------------------------------------

DO $$
DECLARE v INTEGER;
BEGIN
  SELECT ver FROM brmbar_privileged.brmbar_schema INTO v;
  IF v IS NULL THEN
    -- --------------------------------
    -- Legacy Types

    SELECT COUNT(*) INTO v
      FROM pg_catalog.pg_type typ
        INNER JOIN pg_catalog.pg_namespace nsp
          ON nsp.oid = typ.typnamespace
      WHERE nsp.nspname = 'public'
        AND typ.typname='exchange_rate_direction';
    IF v=0 THEN
    RAISE NOTICE 'Creating type exchange_rate_direction';
    CREATE TYPE public.exchange_rate_direction
      AS ENUM ('source_to_target', 'target_to_source');
    ELSE
    RAISE NOTICE 'Type exchange_rate_direction already exists';
    END IF;

    SELECT COUNT(*) INTO v
      FROM pg_catalog.pg_type typ
        INNER JOIN pg_catalog.pg_namespace nsp
          ON nsp.oid = typ.typnamespace
      WHERE nsp.nspname = 'public'
        AND typ.typname='account_type';
    IF v=0 THEN
    RAISE NOTICE 'Creating type account_type';
    CREATE TYPE public.account_type
      AS ENUM ('cash', 'debt', 'inventory', 'income', 'expense',
      	       'starting_balance', 'ending_balance');
    ELSE
    RAISE NOTICE 'Type account_type already exists';
    END IF;

    SELECT COUNT(*) INTO v
      FROM pg_catalog.pg_type typ
        INNER JOIN pg_catalog.pg_namespace nsp
          ON nsp.oid = typ.typnamespace
      WHERE nsp.nspname = 'public'
        AND typ.typname='transaction_split_side';
    IF v=0 THEN
    RAISE NOTICE 'Creating type transaction_split_side';
    CREATE TYPE public.transaction_split_side
      AS ENUM ('credit', 'debit');
    ELSE
    RAISE NOTICE 'Type transaction_split_side already exists';
    END IF;

    -- --------------------------------
    -- Currencies sequence, table and potential initial data

    CREATE SEQUENCE IF NOT EXISTS public.currencies_id_seq
      START WITH 2 INCREMENT BY 1;
    CREATE TABLE IF NOT EXISTS public.currencies (
      	id INTEGER PRIMARY KEY NOT NULL DEFAULT NEXTVAL('public.currencies_id_seq'::regclass),
	name VARCHAR(128) NOT NULL,
	UNIQUE(name)
    );
    INSERT INTO public.currencies (id, name) VALUES (1, 'Kč')
      ON CONFLICT DO NOTHING;

    -- --------------------------------
    -- Exchange rates table - no initial data required

    CREATE TABLE IF NOT EXISTS public.exchange_rates (
	valid_since TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,

	target INTEGER NOT NULL,
        FOREIGN KEY (target) REFERENCES public.currencies (id),

	source INTEGER NOT NULL,
        FOREIGN KEY (source) REFERENCES public.currencies (id),

	rate DECIMAL(12,2) NOT NULL,
	rate_dir public.exchange_rate_direction NOT NULL
    );

    -- --------------------------------
    -- Accounts sequence and table and 4 initial accounts

    CREATE SEQUENCE IF NOT EXISTS public.accounts_id_seq
      START WITH 2 INCREMENT BY 1;
    CREATE TABLE IF NOT EXISTS public.accounts (
	id INTEGER PRIMARY KEY NOT NULL DEFAULT NEXTVAL('public.accounts_id_seq'::regclass),

	name VARCHAR(128) NOT NULL,
	UNIQUE (name),

	currency INTEGER NOT NULL,
        FOREIGN KEY (currency) REFERENCES public.currencies (id),

	acctype public.account_type NOT NULL,

	active BOOLEAN NOT NULL DEFAULT TRUE
    );
    INSERT INTO public.accounts (id, name, currency, acctype)
      VALUES (1, 'BrmBar Cash', (SELECT id FROM public.currencies WHERE name='Kč'), 'cash')
      ON CONFLICT DO NOTHING;
    INSERT INTO public.accounts (name, currency, acctype)
      VALUES ('BrmBar Profits', (SELECT id FROM public.currencies WHERE name='Kč'), 'income')
      ON CONFLICT DO NOTHING;
    INSERT INTO public.accounts (name, currency, acctype)
      VALUES ('BrmBar Excess', (SELECT id FROM public.currencies WHERE name='Kč'), 'income')
      ON CONFLICT DO NOTHING;
    INSERT INTO public.accounts (name, currency, acctype)
    VALUES ('BrmBar Deficit', (SELECT id FROM public.currencies WHERE name='Kč'), 'expense')
    ON CONFLICT DO NOTHING;

    -- --------------------------------
    -- Barcodes
    
    CREATE TABLE IF NOT EXISTS public.barcodes (
	barcode VARCHAR(128) PRIMARY KEY NOT NULL,

	account INTEGER NOT NULL,
        FOREIGN KEY (account) REFERENCES public.accounts (id)
    );
    INSERT INTO public.barcodes (barcode, account)
      VALUES ('_cash_', (SELECT id FROM public.accounts WHERE acctype = 'cash'))
      ON CONFLICT DO NOTHING;

    -- --------------------------------
    -- Transactions
    
    CREATE SEQUENCE IF NOT EXISTS public.transactions_id_seq
      START WITH 1 INCREMENT BY 1;
    CREATE TABLE IF NOT EXISTS public.transactions (
	id INTEGER PRIMARY KEY NOT NULL DEFAULT NEXTVAL('public.transactions_id_seq'::regclass),
	time TIMESTAMP DEFAULT NOW() NOT NULL,

	responsible INTEGER,
	FOREIGN KEY (responsible) REFERENCES public.accounts (id),

	description TEXT
    );

    -- --------------------------------
    -- Transaction splits

    CREATE SEQUENCE IF NOT EXISTS public.transaction_splits_id_seq
      START WITH 1 INCREMENT BY 1;
    CREATE TABLE IF NOT EXISTS public.transaction_splits (
	id INTEGER PRIMARY KEY NOT NULL DEFAULT NEXTVAL('public.transaction_splits_id_seq'::regclass),

	transaction INTEGER NOT NULL,
	FOREIGN KEY (transaction) REFERENCES public.transactions (id),

	side public.transaction_split_side NOT NULL,

	account INTEGER NOT NULL,
        FOREIGN KEY (account) REFERENCES public.accounts (id),
	amount DECIMAL(12,2) NOT NULL,

	memo TEXT
    );

    -- --------------------------------
    -- Account balances view

    CREATE OR REPLACE VIEW public.account_balances AS
      SELECT ts.account AS id,
      accounts.name,
      accounts.acctype,
      - sum(
	  CASE
	      WHEN ts.side = 'credit'::public.transaction_split_side THEN - ts.amount
	      ELSE ts.amount
	  END) AS crbalance
     FROM public.transaction_splits ts
       LEFT JOIN public.accounts ON accounts.id = ts.account
    GROUP BY ts.account, accounts.name, accounts.acctype
    ORDER BY (- sum(
	  CASE
	      WHEN ts.side = 'credit'::public.transaction_split_side THEN - ts.amount
	      ELSE ts.amount
	  END));

    -- --------------------------------
    -- Transaction nice splits view

    CREATE OR REPLACE VIEW public.transaction_nicesplits AS
      SELECT ts.id,
	ts.transaction,
	ts.account,
	    CASE
		WHEN ts.side = 'credit'::public.transaction_split_side THEN - ts.amount
		ELSE ts.amount
	    END AS amount,
	a.currency,
	ts.memo
      FROM public.transaction_splits ts
	 LEFT JOIN public.accounts a ON a.id = ts.account
      ORDER BY ts.id;

    -- --------------------------------
    -- Transaction cash sums view

    CREATE OR REPLACE VIEW public.transaction_cashsums AS
      SELECT t.id,
	 t."time",
	 sum(credit.credit_cash) AS cash_credit,
	 sum(debit.debit_cash) AS cash_debit,
	 a.name AS responsible,
	 t.description
	FROM public.transactions t
	  LEFT JOIN ( SELECT cts.amount AS credit_cash,
		 cts.transaction AS cts_t
		FROM public.transaction_nicesplits cts
		  LEFT JOIN public.accounts a_1 ON a_1.id = cts.account OR a_1.id = cts.account
	       WHERE a_1.currency = (( SELECT accounts.currency
			FROM public.accounts
		       WHERE accounts.name::text = 'BrmBar Cash'::text))
		       AND (a_1.acctype = ANY (ARRAY['cash'::public.account_type, 'debt'::public.account_type]))
		       AND cts.amount < 0::numeric) credit ON credit.cts_t = t.id
	  LEFT JOIN ( SELECT dts.amount AS debit_cash,
		 dts.transaction AS dts_t
		FROM public.transaction_nicesplits dts
		  LEFT JOIN public.accounts a_1 ON a_1.id = dts.account OR a_1.id = dts.account
	       WHERE a_1.currency = (( SELECT accounts.currency
			FROM public.accounts
		       WHERE accounts.name::text = 'BrmBar Cash'::text))
		       AND (a_1.acctype = ANY (ARRAY['cash'::public.account_type, 'debt'::public.account_type]))
		       AND dts.amount > 0::numeric) debit ON debit.dts_t = t.id
	  LEFT JOIN public.accounts a ON a.id = t.responsible
       GROUP BY t.id, a.name
       ORDER BY t.id DESC;

    -- --------------------------------
    -- Function to check schema version (used in migrations)

    CREATE OR REPLACE FUNCTION brmbar_privileged.has_exact_schema_version(
	    IN i_ver INTEGER
    ) RETURNS BOOLEAN
    VOLATILE  NOT LEAKPROOF  LANGUAGE plpgsql AS $x$
    DECLARE
	    v_ver INTEGER;
    BEGIN
	    SELECT ver INTO v_ver FROM brmbar_privileged.brmbar_schema;
	    IF v_ver is NULL THEN
	      RETURN false;
	    ELSE
	      RETURN v_ver = i_ver;
	    END IF;
    END;
    $x$;

    -- --------------------------------
    -- 

    CREATE OR REPLACE FUNCTION brmbar_privileged.upgrade_schema_version_to(
	    IN i_ver INTEGER
    ) RETURNS VOID
    VOLATILE  NOT LEAKPROOF  LANGUAGE plpgsql AS $x$
    DECLARE
	    v_ver INTEGER;
    BEGIN
      SELECT ver FROM brmbar_privileged.brmbar_schema INTO v_ver;
      IF v_ver=(i_ver-1) THEN
        UPDATE brmbar_privileged.brmbar_schema SET ver = i_ver;
      ELSE
        RAISE EXCEPTION 'Invalid brmbar schema version transition (% -> %)', v_ver, i_ver;
      END IF;
    END;
    $x$;

    -- Initialize version 1
    INSERT INTO brmbar_privileged.brmbar_schema(ver) VALUES(1);
  END IF;
END;
$$;
