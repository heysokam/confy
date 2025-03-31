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
# @section Targets
#_____________________________
type Build *{.pure.}= enum None, Program, SharedLib, StaticLib, UnitTest, Object
type BuildTarget * = object
  ## @descr
  ##  Defines the data necessary to compile/run a specific target binary
  ## @note
  ##  Don't use directly. Use {@link Build}.* instead
  ##  eg: Build.Program
  kind     *:Build              ## Type of binary that this BuildTarget represents
  version  *:Version            ## Semantic Version of this target
  src      *:SourceList         ## List of code files used by the compiler to create the resulting binary
  trg      *:PathLike           ## Target Binary that the compiler will output on compilation
  sub      *:PathLike=  ""      ## Subfolder inside cfg.dirs.bin where the target binaries will be output
  cfg      *:Config             ## Project configuration options used by this target
  lang     *:Lang               ## @descr Forces the target to be built with the given {@link Lang} when specified. Will search by file extensions on creation.
  deps     *:Dependencies= @[]  ## List of dependencies required to compile this target
  flags    *:Flags              ## List of Flags used to compile this target
  args     *:ArgsList           ## List of arguments that will be passed to the compiler as they are
  # TODO:
  # system   :std.Build.ResolvedTarget= undefined,
  # optim    :std.builtin.OptimizeMode= undefined,

