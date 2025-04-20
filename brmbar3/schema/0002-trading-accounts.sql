--
-- 0002-trading-accounts.sql
--
-- #2 - add trading accounts to account type type
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

IF brmbar_privileged.has_exact_schema_version(1) THEN

  ALTER TYPE public.account_type ADD VALUE 'trading';
  
  PERFORM brmbar_privileged.upgrade_schema_version_to(2);
END IF;

END;
$upgrade_block$;
