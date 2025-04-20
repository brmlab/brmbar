--RESET search_path
SELECT pg_catalog.set_config('search_path', '', false);

--- upgrade schema
DO $upgrade_block$
DECLARE
current_ver INTEGER;
BEGIN

-- confirm that we are upgrading from version 1
SELECT brmbar_implementation.has_exact_schema_version(1) INTO current_ver;
IF current_ver <> 1 THEN
	RAISE EXCEPTION 'BrmBar schema version % cannot be upgraded to version 2.', current_ver;
END IF;

-- structural changes

-- TRADING ACCOUNTS
--START TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- currency trading accounts - account type
ALTER TYPE public.account_type ADD VALUE IF NOT EXISTS 'trading';

-- constraint needed for foreign key in currencies table
ALTER TABLE public.accounts ADD CONSTRAINT accounts_id_acctype_key UNIQUE(id, acctype);

-- add columns to currencies to record the trading account associated with the currency
ALTER TABLE public.currencies
	ADD COLUMN IF NOT EXISTS trading_account integer,
	ADD COLUMN IF NOT EXISTS trading_account_type account_type GENERATED ALWAYS AS ('trading'::public.account_type) STORED;

-- make trading accounts (without making duplicates)
INSERT INTO public.accounts ("name", "currency", acctype)
SELECT
	'Currency Trading Account: ' || c."name",
	c.id,
	'trading'::public.account_type
FROM public.currencies AS c
WHERE NOT EXISTS (
	SELECT 1
	FROM public.accounts a
	WHERE a.currency = c.id AND a.acctype = 'trading'::public.account_type
);


-- record the trading account IDs in currencies table
UPDATE public.currencies AS c SET (trading_account) = (SELECT a.id FROM public.accounts AS a WHERE a.currency = c.id AND c.acctype = 'trading'::public.account_type);

-- foreign key to check the validity of currency trading account reference
ALTER TABLE public.currencies
	ADD CONSTRAINT currencies_trading_fkey FOREIGN KEY (trading_account, trading_account_type)
		REFERENCES xaccounts(id,acctype) DEFERRABLE INITIALLY DEFERRED;

--COMMIT AND CHAIN;

SELECT brmbar_implementation.upgrade_schema_version_to(2) INTO current_ver;
-- end of upgrade do block
end
$upgrade_block$;

-- vim: set ft=plsql :
