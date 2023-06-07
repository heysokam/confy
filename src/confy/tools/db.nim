#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import std/os
import std/math
import std/times
import std/strformat
import std/strutils
import db_connector/db_sqlite as sqlite
# confy dependencies
import ../types
import ../cfg as c
# Tools dependencies
import ./helper
import ./hash as md5


#_____________________________
# Database internal config
#___________________
const DbTable = "confy_cache"
type Col {.pure.}= enum id, file, time, hash

#_____________________________
# Database Queries
#___________________
const createTable :string= """
CREATE TABLE confy_cache (
  id    INTEGER PRIMARY KEY,
  file  VARCHAR(50) NOT NULL,
  time  VARCHAR(22) NOT NULL,
  hash  VARCHAR(16) NOT NULL
)"""
proc tables  (db :DbConn) :string=  db.getValue(sql"SELECT name FROM sqlite_master WHERE type='table'")
  ## Returns the list of tables stored in the given `db` database
proc entries (db :DbConn; table :string= DbTable) :seq[string]=
  ## Returns the list of entries in the given `db` at table `table`. Will search for `DbTable` when omitted.
  for row in db.fastRows(sql"SELECT * FROM ?", table):
    result.add row[Col.file.ord]
proc get (db :DbConn; col :Col; trg :Fil; table :string= DbTable) :string=
  ## Gets the last `col` value of the given `trg` entry in the `db` database `table`.
  for row in db.fastRows(sql"SELECT * FROM ?", table):
    if row[Col.file.ord] == trg: result = row[col.ord]
proc getTime (db :DbConn; trg :Fil; table :string= DbTable) :string=  db.get(Col.time, trg, table)
  ## Returns the stored modification time of the given `trg` file.
proc getMD5  (db :DbConn; trg :Fil; table :string= DbTable) :string=  db.get(Col.hash, trg, table)
  ## Returns the stored MD5 hash of the given `trg` file.
proc tableExists (db :DbConn; table :string= DbTable) :bool=  table in db.tables
  ## Returns true if the table exists in the given `db` database. Will search for `DbTable` when omitted.
proc add (db :DbConn; trg :Fil; table :string= DbTable) :void=
  ## Adds the given `trg` file into the target database table, using its current time and MD5.
  db.exec(sql"INSERT INTO ? (file, time, hash) VALUES (?, ?, ?)", table, trg, trg.getLastModificationTime, trg.hash)
proc rmv (db :DbConn; trg :Fil; table :string= DbTable) :void=
  ## Removes all entries of the given `trg` file from the target database table.
  db.exec(sql"DELETE FROM ? WHERE file=?", table, trg)
proc reset (db :DbConn; table :string= DbTable) :void=
  ## Resets the `trg` database table. Removes anything that is already stored.
  db.exec(sql"DROP TABLE IF EXISTS ?", table); db.exec(sql(createTable))

#_____________________________
# Database Query Helpers
#___________________
template with (trg :Fil; body :untyped) :void=
  ## Opens the `trg` database file, executes the body, and closes the connection after.
  ## The symbol `db` is accessible inside the body, because it is `{.inject.}`ed.
  let db {.inject.} = trg.open("", "", "") # Open connection
  body        # Run the db calls
  db.close()  # Close connection

#_____________________________
# Modification Checks
#___________________
proc timestamp (db :DbConn; trg :Fil) :bool=  db.getTime(trg) != trg.getLastModificationTime.`$`
  ## Returns true if the file has been modified since it was last tracked, using its timestamp.
proc MD5 (db :DbConn; trg :Fil) :bool=  db.getMD5(trg) != trg.hash
  ## Returns true if the file has been modified since it was last tracked, using its MD5.
proc contains (db :DbConn; trg :Fil) :bool=
  ## Returns false if the file has been modified since it was last tracked, using all conditions.
  if   db.timestamp(trg): result = false
  elif db.MD5(trg):       result = false
  else:                   result = true

#___________________
proc contains *(src, trg :Fil) :bool=
  ## Returns false if the `trg` file has been modified, based on the information stored in the `src` database.
  ## - Only its timestamp is used if the modification time hasn't changed.
  ## - When the timestamp has changed, an MD5 hash check is done on the file.
  ## - Always true When the database doesn't exist.
  let dbFile = src.changeFileExt(".db")
  if not fileExists dbFile: return true
  with dbFile: result = trg in db

#_____________________________
# Database Management
#___________________
const empty :string= staticRead("./db-empty.db")
  ## Stores an empty database for easier database initialization.
#___________________
proc init *(trg :Fil; check :bool= true) :void=
  ## Initializes the `trg` database file.
  ## Check means:
  ## - true:  Creates the file only it doesn't exist
  ## - false: Resets its contents even if the file already exists.
  let dbFile = trg.changeFileExt(".db")
  if check and fileExists dbFile: return
  dbFile.writeFile(empty)
  with dbFile: db.reset()
#___________________
proc add *(trg :Fil; src :seq[Fil]) :void=
  ## Adds the given `src` list of files to the `trg` database.
  ## - Assumes the `src` files have already been checked.
  ## - Any previously existing entries of each `src` file are removed.
  ## - Initializes the `trg` database if it doesn't exist.
  ## - Accepts the `trg` database file basename without extension.
  ## - If `trg` database file has an incorrect extension, it will be changed to `.db`.
  let dbFile = trg.changeFileExt(".db")
  dbFile.init()
  with dbFile:
    # Insert multiple
    db.exec(sql"BEGIN")  # Begin the multi-query
    for file in src:  db.rmv(file); db.add(file)
    db.exec(sql"COMMIT")
#___________________
proc update *(src :Fil; trg :seq[Fil]) :seq[Fil]=
  ## Updates the database with the files that have been modified from the given `trg` file list.
  ## - Runs `chk(src, trg)` on all files in the `trg` list.
  ## - Files that are not tracked yet are just added to the list.
  ## Returns a new list with those files that have been modified.
  let dbFile = src.changeFileExt(".db")
  if not fileExists dbFile: dbFile.init()
  with dbFile:
    for file in trg:
      if file notin db: db.add(file); result.add(file)
      # else:            result.add file.changeFileExt(".o")

