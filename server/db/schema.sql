CREATE TABLE items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  price INTEGER NOT NULL,
  code TEXT NOT NULL
);

CREATE INDEX items_name ON items ( name );
CREATE INDEX items_price ON items ( price );
CREATE UNIQUE INDEX items_code ON items ( code );

CREATE TABLE log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  userid INTEGER NOT NULL,
  itemid INTEGER,
  event TEXT,
  ts INTEGER NOT NULL
);

CREATE INDEX log_userid ON log ( userid );
CREATE INDEX log_itemid ON log ( userid );
CREATE INDEX log_ts ON log ( ts );

CREATE TABLE balance (
  userid INTEGER PRIMARY KEY,
  balance INTEGER NOT NULL
);
