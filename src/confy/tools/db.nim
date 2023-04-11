#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/db_sqlite as sqlite
import std/math
# confy dependencies
import ../types
import ../state as c

# user, password, database name can be empty. They are not used on db_sqlite module.
proc example_short=
  # Open connection
  let db = "mytest.db".open("", "", "")
  # Create a table
  db.exec(sql"DROP TABLE IF EXISTS my_table")
  db.exec(sql"""CREATE TABLE my_table (
                   id   INTEGER,
                   name VARCHAR(50) NOT NULL )""")
  # Insert data
  db.exec(sql"INSERT INTO my_table (id, name) VALUES (0, ?)",
          "Jack")
  # Close connection
  db.close()

proc example_long=
  # Open connection
  let db = "mytest.db".open("", "", "")
  # Create a table
  db.exec(sql"DROP TABLE IF EXISTS my_table")
  db.exec(sql"""CREATE TABLE my_table (
                   id   INTEGER,
                   name VARCHAR(50) NOT NULL )""")
  # Insert multiple
  db.exec(sql"BEGIN")  # Begin the multi-add
  for i in 1..1000:
    db.exec(sql"INSERT INTO my_table (name, i, f) VALUES (?, ?, ?)",
               "Item#" & $i, i, sqrt(i.float))
  db.exec(sql"COMMIT")
  # Read data from the db
  for x in db.fastRows(sql"SELECT * FROM my_table"):
    echo x
  let id = db.tryInsertId(sql"""INSERT INTO my_table (name, i, f) VALUES (?, ?, ?)""",
                             "Item#1001", 1001, sqrt(1001.0))
  echo "Inserted item: ", db.getValue(sql"SELECT name FROM my_table WHERE id=?", id)
  # Close connection
  db.close()


# TODO:
# proc add(files :seq[string])
# proc rmv(files :seq[string])
# proc chk(files :seq[string])

