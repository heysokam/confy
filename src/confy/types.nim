#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import RMV/paths    # Will come from std/paths when nim 2.0 is stable


type Dir  * = Path
  ## Path to a Directory
type Fil  * = Path
  ## Path to a File
  ## Note: Name chosen based on the etymology of the word File, which comes from latin Fillum.
  ##       It's a bad name. Period. But it cannot be just `File` because of std/File conflict.
  ##       Very :NotLikeThis:

type Opt  * = bool
  ## Command line ShortOptions / Switches

type BinKind * = enum Program, SharedLibrary, StaticLibrary
  ## Type of binary that will be output. `.exe`, `.lib`, `.a`, etc

type BuildObj * = object
  kind  *:BinKind
  src   *:seq[Fil]
  trg   *:Fil
  root  *:Dir

