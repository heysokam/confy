#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
# @deps confy
import ./base
import ./config
import ../tools/version

#_______________________________________
# @section Dependencies
#_____________________________
type Submodule = object
  dir *:PathLike ## @descr
    ##  Subfolder used to store the submodule when adding to the main repository
    ##  eg:  git submodule add  URL  Dependency.submodule.dir/Dependency.name
  active *:bool=  false ## @descr
    ##  This Dependency will be treated as a git submodule by the manager when active is true
type
  Dependencies * = seq[Dependency]
  Dependency   * = object
    ## @descr Describes the data needed for resolving Package dependencies
    name *:string  ## @descr
      ##  Name of the Dependency. Used for folder autocompletion when needed.
    url *:URL ## @descr
      ##  Remote URL where the dependency will be downloaded from
    entry *:string= ""  ## @descr
      ##  Entry File that should be treated as the root/entry point of the module/dependency.
      ##  Will use {@link Dependency.name}.ext when empty.
      ##  Must be relative to {@link Dependency.subdir}.
      ##  Must have an extension when not empty.
    src *:PathLike= "src"  ## @descr
      ##  Subfolder of the project where the entry file is stored.
    libDir *:PathLike= ""  ## @descr
      ##  When not empty, override the target's default lib installation subpath with this folder
      ##  Must be relative to the current working directory from where the builder is run.
      ## @note _Provided for completion. This option should almost never be needed._
    deps *:Dependencies = @[]  ## @descr
      ##  Sub-dependencies of this dependency
    submodule *:Submodule  ## @descr
      ##  Options for treating the dependency as a submodule


#_______________________________________
# @section Flags
#_____________________________
type Flag  * = string
type Flags * = object
  ## List of Compiler Flags for a BuildTarget
  cc  *:seq[Flag]= @[]
  ld  *:seq[Flag]= @[]


#_______________________________________
# @section Commands
#_____________________________
type Arg      * = string
type ArgsList * = seq[Arg]
type Command * = object
  args  *:ArgsList


#_______________________________________
# @section Language
#_____________________________
type Lang *{.pure.}= enum Unknown, Asm, C, Cpp, Zig, Nim, Minim


#_______________________________________
# @section Target: Kind and Mode
#_____________________________
type Build *{.pure.}= enum None, Program, SharedLib, StaticLib, UnitTest, Object
type ModeKind  *{.pure.}= enum Debug, Release, Danger
type ModeOptim *{.pure.}= enum None, Speed, Size
type Mode * = object
  kind  *:ModeKind=   Debug
  opt   *:ModeOptim=  None


#_______________________________________
# @section Target System
#_____________________________
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
type ABI *{.pure.}= enum none, gnu, musl
#___________________
type System * = object
  ## Properties of a specific target system
  os   *:OS
  cpu  *:CPU
  abi  *:ABI= ABI.gnu
  explicit  *:bool= false  ## Will always add the `-target` tag to the compilation command when true
type SystemStr * = tuple[os:string,cpu:string,abi:string]
  ## Tuple of (os,cpu,abi) strings, converted to be valid for use as arguments for specific commands.
#___________________
type Extension * = object
  ## File extensions for a system.
  os    *:OS
  bin   *:PathLike
  lib   *:PathLike
  obj   *:PathLike
  ar    *:PathLike
#___________________
type Extensions * = object
  unix  *:Extension
  win   *:Extension
  mac   *:Extension
#___________________
func `[]` *(E :Extension; kind :Build) :PathLike=
  case kind
  of Program,
     UnitTest  : E.bin
  of SharedLib : E.lib
  of StaticLib : E.ar
  of Object    : E.obj
  of None      : ""
#___________________
func `[]` *(E :Extensions; os :OS) :Extension=
  case os
  of Windows : E.win
  of Mac     : E.mac
  else       : E.unix
#___________________
const extensions * = Extensions(
  # @note Remember:
  # https://github.com/nim-lang/Nim/blob/devel/compiler/platform.nim#L46
  unix: Extension(os: OS.Linux,   bin: "",     lib: ".so",    obj: ".o",   ar: ".a"  ),
  win:  Extension(os: OS.Windows, bin: ".exe", lib: ".dll",   obj: ".obj", ar: ".lib"),
  mac:  Extension(os: OS.Mac,     bin: ".app", lib: ".dylib", obj: ".o",   ar: ".a"  ),
  ) #:: ext


#_______________________________________
# @section Targets
#_____________________________
type BuildTarget * = object
  ## @descr
  ##  Defines the data necessary to compile/run a specific target binary
  ## @note
  ##  Don't use directly. Use {@link Build}.* instead
  ##  eg: Build.Program
  kind     *:Build              ## Type of binary that this BuildTarget represents
  mode     *:build.Mode         ## Mode in which the resulting binary will be built  (default: Debug.None)
  version  *:Version            ## Semantic Version of this target
  src      *:SourceList         ## List of code files used by the compiler to create the resulting binary
  trg      *:PathLike           ## Target Binary that the compiler will output on compilation
  sub      *:PathLike=  ""      ## Subfolder inside cfg.dirs.bin where the target binaries will be output
  cfg      *:Config             ## Project configuration options used by this target
  lang     *:Lang               ## Forces the target to be built with the given {@link Lang} when specified. Will search by file extensions on creation.
  deps     *:Dependencies= @[]  ## List of dependencies required to compile this target
  flags    *:Flags              ## List of Flags used to compile this target
  args     *:ArgsList           ## List of arguments that will be passed to the compiler as they are
  system   *:System             ## OS/CPU/ABI that the compiler will build for. Will be host when omitted. (eg: linux.x86_64.gnu)
  # TODO:
  # optim    :std.builtin.OptimizeMode= undefined,
  # remotes  *:seq[Dir]      ## @field remotes Remote folders to search for files (in order), when they are not found in the main folder.

