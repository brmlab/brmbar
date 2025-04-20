--
-- 0008-update-currency-buy-rate.sql
--
-- #8 - stored procedure for updating buy rate
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

-- Require fully-qualified names
SELECT pg_catalog.set_config('search_path', '', false);

DO $upgrade_block$
BEGIN

IF brmbar_privileged.has_exact_schema_version(7) THEN

  CREATE OR REPLACE FUNCTION public.update_currency_buy_rate(
    IN i_currency public.exchange_rates.target%TYPE,
    IN i_source public.exchange_rates.source%TYPE,
    IN i_rate public.exchange_rates.rate%TYPE
  ) RETURNS VOID LANGUAGE plpgsql AS $$
  BEGIN
    INSERT INTO public.exchange_rates(source, target, rate, rate_dir)
      VALUES (i_source, i_currency, i_rate, 'target_to_source');
  END
  $$;
  
  PERFORM brmbar_privileged.upgrade_schema_version_to(8);
END IF;

END;
$upgrade_block$;
