#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps confy
import ./base
import ./config


#_______________________________________
# @section Commands
#_____________________________
type CommandParts * = seq[string]
type Command * = object
  parts  *:CommandParts


#_______________________________________
# @section Language
#_____________________________
type Lang *{.pure.}= enum Unknown, Asm, C, Cpp, Zig, Nim, Minim


#_______________________________________
# @section Targets
#_____________________________
type Build *{.pure.}= enum None, Program, SharedLib, StaticLib, UnitTest, Object
# @note
#  Don't use directly. Use Build.* instead
#  eg: Build.Program
type BuildTarget = object
  kind   *:Build
  src    *:SourceList
  trg    *:PathLike
  cfg    *:Config
  lang   *:Lang

