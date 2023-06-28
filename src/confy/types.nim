#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
when defined(nimscript):
  from std/os import DirSep
  proc `/`*(p1,p2 :string) :string=  p1 & DirSep & p2
  type Path * = string
else:
  import std/os
  import std/paths

type Dir  * = Path
  ## Path to a Directory
type Fil  * = Path
  ## Path to a File
  ## Note: Name chosen based on the etymology of the word File, which comes from latin Fillum.
  ##       It's a bad name. Period. But it cannot be just `File` because of std/File conflict.
  ##       Very :NotLikeThis:
type DirFile * = object
  ## Internal Data Type for a single file, so that dir can be adjusted separately without issues. file is always relative to dir
  dir   *:Dir
  file  *:Fil

type CompileError * = object of IOError
  ## For exceptions during the compile process
type GeneratorError * = object of IOError
  ## For exceptions during code generation.

type Opt  * = bool
  ## Command line ShortOptions / Switches

type Lang *{.pure.}= enum Unknown, C, Cpp, Nim
  ## Language of a code file, based on its extension
type BinKind * = enum Program, SharedLibrary, StaticLibrary, Object, Module
  ## Type of binary that will be output. `.exe`, `.lib`, `.a`, `.o`, etc

type Flags * = object
  ## Set of flags to send to the compiler stages.
  cc *:seq[string]
  ld *:seq[string]

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

type Extension * = object
  ## File extensions for a system.
  os    *:OS
  bin   *:string
  lib   *:string
  obj   *:string
type Extensions * = object
  unix  *:Extension
  win   *:Extension
  mac   *:Extension
const ext * = Extensions(
  unix: Extension(os: OS.Linux,   bin: "",     lib: ".so",    obj: ".o"),
  win:  Extension(os: OS.Windows, bin: ".exe", lib: ".dll",   obj: ".obj"),
  mac:  Extension(os: OS.Mac,     bin: ".app", lib: ".dylib", obj: ".o"),  )

type Compiler * = enum Zig, GCC, Clang
  ## Known compiler names.

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
  # Internals
  lang     *:Lang          ## Main language of the app. Having any cpp files will make the app be Cpp

