#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/os
import std/times
# @deps ndk
import nstd/strings
import nstd/shell ; export shell except git, sh
# @deps confy
import ../types
import ../cfg


#_______________________________________
# General Tools
#_____________________________
# Bash
proc sh *(cmd :string; dbg :bool= false) :void=
  ## @descr Runs the given command in a shell (binary).
  if dbg: echo cmd
  if cfg.fakeRun: return
  if os.execShellCmd(cmd) != 0: raise newException(OSError, &"Failed to run shell command:  {cmd}")
#___________________
# Access time
when not nims:
  from nstd/paths import lastMod, noModSince
  export lastMod, noModSince
#_____________________________
# Files
proc setExec *(trg :Fil) :void=  os.setFilePermissions(trg.string, {FilePermission.fpUserExec}, followSymlinks = false)
  ## @descr Sets the given `trg` binary flags to be executable for the current user.


#_______________________________________
# Compiler
#_____________________________
proc defaultExt *(lang :Lang) :string=
  ## @descr Returns the default extension for the given lang as a string  (contains the dot).
  ## @note Result will be an empty string if the lang is Unknown
  case lang
  of Nim,C,Cpp : "." & ($lang).normalize
  of MinC      : ".cm"
  of Asm       : ".s"
  of Unknown   : ""

