#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
from std/sets import OrderedSet, Hashset, items
from std/hashes import Hash, hash
from std/tables import Table
from std/sequtils import anyIt, toSeq
# @deps ndk
from nstd/paths import Path, `==`, contains, `<`
from confy/types as confy import System, BuildMode, CPU, OS, BinKind


#_____________________________
# Forward types required by other files
export confy.System, confy.BuildMode, confy.CPU, confy.OS
export OrderedSet, Hashset


#_____________________________
type MakeInput * = tuple[name: string, dir:Path, root:Path, key:string]
  ## @descr Inputs defined for sending them to make in batch
type MakeInputs * = seq[MakeInput]

#_____________________________
type MakeList * = object
  ## @descr Raw output of the make command
  name  *:string       ## Identifiable name for the list. Will become the name of the temp file.
  file  *:Path         ## Basename of the file where the temporary list of make commands will be output
  key   *:string       ## Keyword used to get the data
  res   *:seq[string]  ## List of lines output by the command
  dir   *:Path         ## Folder where the conversion result should be output
  root  *:Path         ## Project folder where source code folder is stored
type MakeLists * = seq[MakeList]


#_____________________________
type ToCPUFunc        * = proc (cpu :string) :CPU {.nimcall.}
type ToOSFunc         * = proc (os :string) :OS {.nimcall.}
type GetSystemFunc    * = proc (trg :Path; toOS :ToOSFunc; toCPU :ToCPUFunc) :System {.nimcall.}
type GetModeFunc      * = proc (trg :string) :BuildMode {.nimcall.}
type SplitTargetFunc  * = proc (trg :Path) :tuple[bin:Path, binDir:Path, subDir:Path] {.nimcall.}
type PostProccessFunc * = proc (content :string) :string {.nimcall.}
type RenameFunc       * = proc (name :string) :string {.nimcall.}
func RenameFunc_default *(name :string) :string= name


#_____________________________
type CodeFile * = object
  ## @descr
  ##  C file with its respective flags used to build it
  ##  For storing temporary code files with their flags during IR generation
  file  *:Path
  flags *:OrderedSet[string]
type CodeFiles * = seq[CodeFile]
#_____________________________
func contains *(list :CodeFiles; file :Path) :bool=  list.anyIt( (it.file in file) or (file in it.file) )
  ## @descr
  ##  Returns true if the seq of CodeFiles contains the file's name, or viceversa.
  ##  Used by the keywords `in` and `notin`
func contains *(list :OrderedSet[CodeFile]; file :Path) :bool=  list.toSeq.anyIt( (it.file in file) or (file in it.file) )  # check both cases, for when one is relative and the other isnt
  ## @descr
  ##  Returns true if the given list of CodeFiles contains the given file string.
  ##  Used by the keywords `in` and `notin`
#_____________________________
type CodeSet * = Table[Path, Hashset[Path]]
  ## @descr
  ##  List of folders and their unique list of files.
  ##  For storing temporary glob and exception lists for IR generation


#_____________________________
type CTarget *{.inheritable.}= object
  ## Compilation target
  kind  *:BinKind             ## Program, SharedLib, etc
  trg   *:Path                ## Output binary resulting from compilation
  cc    *:string              ## Command used to build the file
  src   *:OrderedSet[Path]    ## List of files used to compile this target
  flags *:OrderedSet[string]  ## List of flags used to compile this target
type CTargets * = seq[CTarget]
# Hash management for CTarget, OrderedSets freak out without them
proc hash *(obj :CTarget) :Hash=  hash(obj.trg.string)
proc `==` *(a,b :CTarget) :bool=  a.trg == b.trg
#_____________________________
type RootTarget * = object of CTarget
  ## Resulting binary and its compilation target dependencies
  root   *:Path                 ## Folder that contains the Makefile. Source code files are relative to this folder
  deps   *:OrderedSet[CTarget]  ## List of other targets required to compile this target
type RootTargets * = seq[RootTarget]
# Hash management for RootTarget, OrderedSets freak out without them
proc hash *(obj :RootTarget) :Hash=  hash(obj.trg.string)
proc `==` *(a,b :RootTarget) :bool=  a.trg == b.trg


#_____________________________
type DirKind * = enum Glob, Excp
type CodeDir * = object
  case kind *:DirKind
  of Glob: discard
  of Excp: filters *:Hashset[Path]
  dir      *:Path
  pattern  *:string              ## Pattern that file searching will match to create the list
  cflags   *:OrderedSet[string]  ## Set of Compiler Flags used to compile all source code in this folder
type CodeDirs * = seq[CodeDir]


#_____________________________
type FinalTarget * = object
  ## @descr Intermediate Representation (IR) Data that describes a single final binary compiled from Make
  bin      *:Path                ## Output binary that results from compilation
  binDir   *:Path                ## Folder where the binary will be output
  subDir   *:Path                ## Subdir of binDir where the binary will be output
  mode     *:BuildMode           ## release/debug
  kind     *:BinKind             ## Program, SharedLib, etc
  system   *:System              ## CPU/OS
  deps     *:CodeFiles           ## Explicit list of dependency files to add to the target. Taken from cfg.binDir
  src      *:CodeFiles           ## Explicit list of source files to add to the target. Taken from cfg.srcDir
  globs    *:CodeDirs            ## Folders that can be globbed entirely
  excepts  *:CodeDirs            ## Folders that need to be filtered in some way
  lflags   *:OrderedSet[string]  ## Set of Linker Flags to compile this binary target
type FinalTargets * = seq[FinalTarget]


#_____________________________
type CodegenList * = object
  ## @descr List of binaries compiled from a single Make keyword
  name     *:string        ## Identifiable name for the list. Will become the name of the temp file.
  key      *:string        ## Keyword passed to make to create the data
  trg      *:FinalTargets  ## List of targets output by this command
  genDir   *:Path          ## Folder where the conversion result should be output
  srcDir   *:Path          ## Project folder where source code folder is stored
  rootDir  *:Path          ## Root folder of the project where make is called from
type CodegenLists * = seq[CodegenList]


#_____________________________
type Connector * = object
  ## @descr Final file that needs to be connected from the main builder.nim codegen file
  path    *:Path
  mode    *:BuildMode
  system  *:System
type Connectors * = seq[Connector]

