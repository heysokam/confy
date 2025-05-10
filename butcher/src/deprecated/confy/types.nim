#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
## @fileoverview
##  Types and global defines for the `confy` library.
#_____________________________________________________|
const debug *:bool= not (defined(release) or defined(danger)) or defined(debug)
const nims  *:bool= defined(nimscript)
#_______________________________________
# @deps std
from std/sets import HashSet
when nims:
  type Path * = string
else:
  from std/paths import Path
# @deps ndk
from nstd/types as nstd import nil



#_______________________________________
# @section Paths
#___________________
type Dir  * = Path
  ## @descr Path to a Directory
type Fil  * = Path
  ## @descr Path to a File
  ## @note
  ##  Name chosen based on the etymology of the word File, which comes from latin Fillum.
  ##  It's a bad name. Period. But it cannot be just `File` because of std/File conflict.
  ##  Very :NotLikeThis:
type DirFile * = object
  ## @descr Internal Data Type for a single file, so that dir can be adjusted separately without issues.
  ## @field dir Absolute folder where the file is stored
  ## @field file Always relative to {@link:field dir}
  dir   *:Dir
  file  *:Fil


type Dependencies * = HashSet[Dependency]


#_______________________________________
# @section Target-specific
#___________________

#_______________________________________
# @section Other Options
#___________________
type Name * = object
  short  *:string
  long   *:string
  human  *:string
type Repository * = object
  server *:string= "https://github.com"
  owner  *:string
  name   *:string
type BuildMode * = enum Release, Debug

