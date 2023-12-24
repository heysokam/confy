#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
## @fileoverview
##  Types and global defines for the `confy` library.
#_____________________________________________________|
const debug *:bool= not (defined(release) or defined(danger)) or defined(debug)
from ./tool/nims as n import nil
const nims *:bool= n.isActive()
#_______________________________________
# @deps std
when nims:
  type Path * = string
else:
  from std/paths import Path

#_________________________________________________
# Error Management
#___________________
type CompileError * = object of IOError
  ## @descr For exceptions during the compile process
type GeneratorError * = object of IOError
  ## @descr For exceptions during code generation.


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


#_______________________________________
# Compiler
#___________________
type Lang *{.pure.}= enum Unknown, C, Cpp, Nim
  ## @descr Language of a code file, based on its extension
type BinKind * = enum Program, SharedLibrary, StaticLibrary, Object, Module
  ## @descr Type of binary that will be output. `.exe`, `.lib`, `.a`, `.o`, etc
#___________________
type Flags * = object
  ## @descr Set of flags to send to the compiler stages.
  cc *:seq[string]
  ld *:seq[string]
#___________________
type Compiler * = enum Zig, GCC, Clang
  ## @descr Known compiler names.


#_______________________________________
# Target-specific
#___________________
type OS * = enum
  Windows = "windows", Mac     = "macosx",  Linux   = "linux"
  NetBSD  = "netbsd",  FreeBSD = "freebsd", OpenBSD = "openbsd"
  Solaris = "solaris", Aix     = "aix",     Haiku   = "haiku",  Other   = "standalone"
type CPU *{.pure.}= enum
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
# Build Target
#___________________
type BuildTrg * = object
  kind     *:BinKind       ## Type of build target
  src      *:seq[DirFile]  ## Sequence of source files to build with. Object files (aka `.o`, etc) will be linked at the end and their path won't be adjusted.
  trg      *:Fil           ## Output binary to build
  cc       *:Compiler      ## Compiler that will be used to build the app.
  # Optional fields
  flags    *:Flags         ## Set of flags to send to each compiler stage
  syst     *:System        ## Target system of the build object  (eg: linux.x86_64). Will be host when omitted.
  root     *:Dir           ## Root folder of the output. Will be: `binDir` when omitted, `root` when absolute, and `binDir/root` when relative.
  sub      *:Dir           ## Subfolder where the source code files will be remapped to, relative to cfg.srcDir. For when the root of src is in srcDir/sub instead
  remotes  *:seq[Dir]      ## Remote folders to search for files (in order), when they are not found in the main folder.
  version  *:string        ## Version string. Currently used for info reports in CLI with `BuildTrg.print()`.
  args     *:string        ## Extra arguments to send to the compiler command. Will be added right at the end.
  # Internals
  lang     *:Lang          ## Main language of the app. Having any cpp files will make the app be Cpp

