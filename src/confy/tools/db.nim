#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import confy/RMV/os
import std/db_sqlite as sqlite
import std/math
import std/times
# confy dependencies
import ../types
import ../cfg as c
# Tools dependencies
import ./helper
import ./hash as md5

#_____________________________
# Database Queries
#___________________
const createTable :string= """
CREATE TABLE confy_cache (
  id    INTEGER PRIMARY KEY,
  file  VARCHAR(50) NOT NULL,
  time  VARCHAR(22) NOT NULL,
  hash  VARCHAR(16) NOT NULL,
)"""
proc getTime (db :DbConn; trg :Fil) :string=  db.getValue(sql"SELECT time FROM confy_cache WHERE file=?", trg)
  ## Returns the stored modification time of the given `trg` file.
proc getMD5  (db :DbConn; trg :Fil) :string=  db.getValue(sql"SELECT hash FROM confy_cache WHERE file=?", trg)
  ## Returns the stored MD5 hash of the given `trg` file.
proc add     (db :DbConn; trg :Fil) :void=    db.exec(sql"INSERT INTO confy_cache (file, time, hash) VALUES (?, ?, ?)", trg, trg.getLastModificationTime, trg.hash)
  ## Adds the given `trg` file into the database, using its current time and MD5.
proc rmv     (db :DbConn; trg :Fil) :void=    db.exec(sql"DELETE FROM confy_cache WHERE file=?", trg)
  ## Removes all entries of the given `trg` file from the database.
proc reset   (db :DbConn) :void=              db.exec(sql"DROP TABLE IF EXISTS confy_cache"); db.exec(sql(createTable))
  ## Resets the `trg` database table. Removes anything that is already stored.

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
proc chk (db :DbConn; trg :Fil) :bool=
  ## Returns true if the file has been modified since it was last tracked, using all conditions.
  if   db.timestamp(trg): result = true; db.rmv(trg)
  elif db.MD5(trg):       result = true; db.rmv(trg)
  else:                   result = false
#___________________
proc chk *(src, trg :Fil) :bool=
  ## Checks if the `trg` file has been modified, based on the information stored in the `src` database.
  ## - Only its timestamp is used if the modification time hasn't changed.
  ## - When the timestamp has changed, an MD5 hash check is done on the file.
  ## - Always true When the database doesn't exist.
  let dbFile = src.changeFileExt(".db")
  if not fileExists dbFile: return true
  with dbFile: result = db.chk(trg)

#_____________________________
# Database Management
#___________________
proc init *(trg :Fil) :void=
  ## Initializes the `trg` database file.
  ## - Accepts the file basename without extension.
  ## - Creates the file if it doesn't exist, and resets its contents if it does.
  let dbFile = trg.changeFileExt(".db")
  dbFile.touch()
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
  if not fileExists dbFile: dbFile.init()
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
      if db.chk(file): db.add(file); result.add(file)

