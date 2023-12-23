#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
## @fileoverview
##  Types and global defines for the `confy` library.
#_____________________________________________________|
const debug *:bool= not (defined(release) or defined(danger)) or defined(debug)
const nims  *:bool=
  when defined(nimscript): true
  else:
    try: gorgeEx("echo").exitCode.bool except: false
    # @hack Should be just `when defined(nimscript)`, but it seems to fail and this just works.
#_______________________________________
# @deps std
when nims:
  type Path * = string
else:
  import std/paths

#_________________________________________________
# Package information
#___________________
type Package * = object
  name        *:string
  version     *:string
  author      *:string
  description *:string
  license     *:string

#_______________________________________
# Paths
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

