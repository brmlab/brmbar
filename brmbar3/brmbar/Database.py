"""self-reconnecting database object"""

import psycopg2
from contextlib import closing
import time

class Database:
    """self-reconnecting database object"""
    def __init__(self, dsn):
        self.db_conn = psycopg2.connect(dsn)
        self.dsn = dsn

    def execute(self, query, attrs = None):
        """execute a query and return one result"""
        with closing(self.db_conn.cursor()) as cur:
            cur = self._execute(cur, query, attrs)

    def execute_and_fetch(self, query, attrs = None):
        """execute a query and return one result"""
        with closing(self.db_conn.cursor()) as cur:
            cur = self._execute(cur, query, attrs)
            return cur.fetchone()

    def execute_and_fetchall(self, query, attrs = None):
        """execute a query and return all results"""
        with closing(self.db_conn.cursor()) as cur:
            cur = self._execute(cur, query, attrs)
            return cur.fetchall()

    def _execute(self, cur, query, attrs, level=1):
        """execute a query, and in case of OperationalError (db restart)
        reconnect to database. Recurses with increasig pause between tries"""
        try:
            if attrs is None:
                cur.execute(query)
            else:
                cur.execute(query, attrs)
            return cur
        except psycopg2.DataError as error: # when biitr comes and enters '99999999999999999999' for amount
            print("We have invalid input data (SQLi?): level %s (%s) @%s" % (
                level, error, time.strftime("%Y%m%d %a %I:%m %p")
                ))
            self.db_conn.rollback()
            raise RuntimeError("Unsanitized data entered again... BOBBY TABLES")
        except psycopg2.OperationalError as error:
            print("Sleeping: level %s (%s) @%s" % (
                level, error, time.strftime("%Y%m%d %a %I:%m %p")
                ))
            #TODO: emit message "db conn failed, reconnecting
            time.sleep(2 ** level)
            try:
                self.db_conn = psycopg2.connect(self.dsn)
            except psycopg2.OperationalError:
                #TODO: emit message "psql not running to interface
                time.sleep(1)
            cur = self.db_conn.cursor()  #how ugly is this?
            return self._execute(cur, query, attrs, level+1)

    def commit(self):
        """passes commit to db"""
        self.db_conn.commit()
