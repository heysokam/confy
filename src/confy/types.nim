#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
type Dir     * = string
type File    * = string
type Opt     * = string
type BinKind * = enum Program, SharedLibrary, StaticLibrary

type BuildObj * = object
  kind  *:BinKind
  src   *:seq[File]

