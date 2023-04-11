#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# std dependencies
import confy/RMV/paths    # Will come from std/paths when nim 2.0 is stable


type Dir  * = Path
  ## Path to a Directory
type Fil  * = Path
  ## Path to a File
  ## Note: Name chosen based on the etymology of the word File, which comes from latin Fillum.
  ##       It's a bad name. Period. But it cannot be just `File` because of std/File conflict.
  ##       Very :NotLikeThis:
type TU * = object
  ## Data for a single Translation Unit   (? Might be the same as BuildTrg ?)
  src  *:seq[Path]
  trg  *:Path

type Opt  * = bool
  ## Command line ShortOptions / Switches

type BinKind * = enum Program, SharedLibrary, StaticLibrary
  ## Type of binary that will be output. `.exe`, `.lib`, `.a`, etc

type OS * = enum
  Windows = "windows", Mac     = "macosx",  Linux   = "linux"
  NetBSD  = "netbsd",  FreeBSD = "freebsd", OpenBSD = "openbsd"
  Solaris = "solaris", Aix     = "aix",     Haiku   = "haiku",  Other   = "standalone"
type CPU *{.pure.}= enum
  x86     = "i386",    x86_64    = "amd64",     arm         = "arm",         arm64 = "arm64",
  mips    = "mips",    mipsel    = "mipsel",    mips64      = "mips64",      mips64el = "mips64el", 
  powerpc = "powerpc", powerpc64 = "powerpc64", powerpc64el = "powerpc64el", sparc = "sparc",
  riscv32 = "riscv32", riscv64   = "riscv64",   alpha       = "alpha",       unknown = "unknown",
type System * = object
  ## Properties of a specific target system
  os   *:OS
  cpu  *:CPU

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

type BuildTrg * = object
  kind  *:BinKind
  src   *:seq[Fil]
  trg   *:Fil
  root  *:Dir
  syst  *:System   ## Target system of the build object  (eg: linux.x86_64)

