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
type OS *{.pure.}= enum
  UndefinedOS = "UndefinedOS",
  Windows = "windows", Mac     = "macosx",  Linux   = "linux"
  NetBSD  = "netbsd",  FreeBSD = "freebsd", OpenBSD = "openbsd"
  Solaris = "solaris", Aix     = "aix",     Haiku   = "haiku",  Other   = "standalone"
type CPU *{.pure.}= enum
  UndefinedCPU = "UndefinedCPU",
  x86     = "i386",    x86_64    = "amd64",     arm         = "arm",         arm64    = "arm64",
  mips    = "mips",    mipsel    = "mipsel",    mips64      = "mips64",      mips64el = "mips64el", 
  powerpc = "powerpc", powerpc64 = "powerpc64", powerpc64el = "powerpc64el", sparc    = "sparc",
  riscv32 = "riscv32", riscv64   = "riscv64",   alpha       = "alpha",       unknown  = "unknown",
type System * = object
  ## Properties of a specific target system
  os   *:OS
  cpu  *:CPU
type SystemStr * = tuple[os:string,cpu:string]
  ## Pair of (os,cpu) strings, converted to be valid for use as arguments for specific commands.
#___________________
type Extension * = object
  ## File extensions for a system.
  os    *:OS
  bin   *:string
  lib   *:string
  obj   *:string
  ar    *:string
type Extensions * = object
  unix  *:Extension
  win   *:Extension
  mac   *:Extension
const ext * = Extensions(
  unix: Extension(os: OS.Linux,   bin: "",     lib: ".so",    obj: ".o",   ar: ".a"),
  win:  Extension(os: OS.Windows, bin: ".exe", lib: ".dll",   obj: ".obj", ar: ".lib"),
  mac:  Extension(os: OS.Mac,     bin: ".app", lib: ".dylib", obj: ".o",   ar: ".a"),  )

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


#_______________________________________
# @section Build Target
#___________________
type BuildTrg * = object
  # Optional fields
  syst     *:System        ## @field syst Target system of the build object  (eg: linux.x86_64). Will be host when omitted.
  root     *:Dir           ## @field root Root folder of the output. Will be: `binDir` when omitted, `root` when absolute, and `binDir/root` when relative.
  sub      *:Dir           ## @field sub Subfolder where the source code files will be remapped to, relative to cfg.srcDir. For when the root of src is in srcDir/sub instead
  remotes  *:seq[Dir]      ## @field remotes Remote folders to search for files (in order), when they are not found in the main folder.

