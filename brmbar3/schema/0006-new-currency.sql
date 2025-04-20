--
-- 0006-new-currency.sql
--
-- #6 - stored procedure for creating new currency
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

IF brmbar_privileged.has_exact_schema_version(5) THEN

  CREATE OR REPLACE FUNCTION public.create_currency(
    IN i_name public.currencies.name%TYPE
  ) RETURNS INTEGER LANGUAGE plpgsql AS $$
  DECLARE
    r_id INTEGER;
  BEGIN
    INSERT INTO public.currencies (name)
      VALUES (i_name) RETURNING id INTO r_id;
    RETURN r_id;
  END
  $$;
  
  PERFORM brmbar_privileged.upgrade_schema_version_to(6);
END IF;

END;
$upgrade_block$;
