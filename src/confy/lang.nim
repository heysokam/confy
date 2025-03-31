#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps std
from std/paths import Path
# @deps confy
import ./types/base
import ./types/build

func identifyExt *(_:typedesc[Lang]; ext :string) :Lang=
  ## Returns the language of the {@arg ext} file extension.
  result = case ext
  of ".s",   "s"   : Lang.Asm
  of ".c",   "c"   : Lang.C
  of ".cc",  "cc",
     ".cpp", "cpp" : Lang.Cpp
  of ".zig", "zig" : Lang.Zig
  of ".nim", "nim" : Lang.Nim
  of ".cm",  "cm",
     ".zm",  "zm"  : Lang.Minim
  else:Lang.Unknown


func identify *(_:typedesc[SourceFile]; src :SourceFile) :Lang=
  ## Returns the language of the {@arg src} file, based on its extension.
  let ext = paths.splitFile(src.Path).ext
  return Lang.identifyExt(ext)


func identify *(_:typedesc[SourceList]; src :SourceList) :Lang=
  ## Returns the language of the {@arg src} list of files, based on their extension.
  var langs :set[Lang]= {}
  for file in src: langs.incl(SourceFile.identify(file))
  result =
    if Lang.Nim   in langs: Lang.Nim
  elif Lang.Minim in langs: Lang.Minim
  elif Lang.Zig   in langs: Lang.Zig
  elif Lang.Cpp   in langs: Lang.Cpp
  elif Lang.C     in langs: Lang.C
  elif Lang.Asm   in langs: Lang.Asm
  else:Lang.Unknown


func identify *(_:typedesc[Lang]; src :SourceList|SourceFile) :Lang=
  ## @descr Returns the language of the {@arg src} file or list of files, based on their extension.
  when src is SourceList : return SourceList.identify(src)
  else                   : return SourceFile.identify(src)

