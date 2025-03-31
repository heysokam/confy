#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
from std/strutils  as chars import nil
from std/strformat import `&`

type Major = uint64
type Minor = uint64
type Patch = uint64
type Tag   = string
type Build = string

type Version * = object
  major  *:version.Major= 0
  minor  *:version.Minor= 0
  patch  *:version.Patch= 0
  tag    *:version.Tag  = ""
  build  *:version.Build= ""

func toString *(V :Version) :string {.inline.}= &"{$V.major}.{$V.major}.{$V.major}{V.tag}{V.build}"
template `$`  *(V :Version)= V.toString()

func version *(
    M : version.Major= 0;
    m : version.Minor= 0;
    p : version.Patch= 0;
    t : version.Tag  = "";
    b : version.Build= "";
  ) :Version {.inline.}= Version(major:M, minor:m, patch:p, tag:t, build:b)

func parse *(_:typedesc[Version]; vers :string) :Version= Version()
func version *(vers :string) :Version {.inline.}= Version.parse(vers)


# TODO:
# type LexState {.pure.}= enum None, Start, Major, Minor, Patch, Tag, Build, Error
# type LexError = object of CatchableError
# func lex_start (
#     ch   : char;
#     vers : string;
#     next : var LexState;
#     curr : var LexState;
#   ) :Version=
#   curr = Error
#   next = Error
#   raise newException(LexError, "Whitespace characters are not allowed in Semantic Versions")
#
# func lex_whitespace (
#     ch   : char;
#     vers : string;
#     next : var LexState;
#     curr : var LexState;
#   ) :Version=
#   curr = Error
#   next = Error
#   raise newException(LexError, "Whitespace characters are not allowed in Semantic Versions")
#
# func lex_update (
#     value :var string;
#     curr  :var LexState;
#     next  :var LexState;
#     vers  :Version
#   ) :void=
#   if next == curr: return
#
# func parse *(_:typedesc[Version]; vers :string) :Version=
#   var curr  :LexState
#   var next  :LexState
#   var value :string= ""
#   for ch in vers:
#     case ch
#     of '.': value = ""; next.inc
#
#     of chars.Whitespace: lex_whitespace(ch, vers, curr, next)
#     of chars.Digits:
#       curr.add ch
#
#     of chars.Letters:
#       curr.add ch
#     else:discard
#     lex_update(value, curr, next, result)
#

