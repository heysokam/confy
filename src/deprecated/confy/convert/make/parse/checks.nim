#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
from std/os import DirSep
from std/sequtils import anyIt, toSeq
from std/sets import len, items
# @deps ndk
import nstd/strings
import nstd/paths
# @deps make.parse
import ../types


#_______________________________________
# @section Make Parser Checks
#_____________________________
const echo = debugEcho
const KnownCommands * = ["cc", "gcc", "osxcross"] ## List of known Compiler commands
const KnownSkips    * = ["-MMD", "\\", "", "echo", "make", "targets", "if", "for", "do", "done", "cp", "cat", "mkdir", "rm"]
const KnownDefines  * = ["make[", "B=", "CFLAGS=", "LDFLAGS=", "V=", "OPTIMIZE=", "CLIENT_CFLAGS="]
const KnownSwitches * = ["-o", "-c", "-i"]  # -i windres
const KnownObjects  * = [".o", ".obj"]
const KnownSources  * = [".c", ".cc", ".cpp"]
const KnownAsmLangs * = ["assembler-with-cpp"]
func isCmd     *(input :string) :bool=  KnownCommands.anyIt( input.endsWith(it) )
func isSkip    *(input :string) :bool=  input in KnownSkips or KnownDefines.anyIt( input.startsWith(it) )
func isSwitch  *(input :string) :bool=  input in KnownSwitches
func isObj     *(input :string) :bool=  KnownObjects.anyIt( input.endsWith(it) )
func isSrc     *(input :string) :bool=  KnownSources.anyIt( input.endsWith(it) )
func isPath    *(input :string) :bool=  DirSep in input
func isAsmLang *(input :string) :bool=  input in KnownAsmLangs
func isFlag    *(input :string) :bool=  (input.startsWith("-") and not input.isSwitch()) or input.isAsmLang()
func isKnown   *(input :string) :bool=  input.isCmd() or input.isSkip() or input.isPath() or input.isFlag()
#_______________________________________
func getTrg *(line :seq[string]) :Path=
  ## @descr The target of this line is always to the right of the `-o` switch
  for id,word in line.pairs:
    if not word.startsWith("-"): continue
    if word == "-o": return line[id+1].Path
#_______________________________________
func isBinary *(line :seq[string]) :bool=  not line.anyIt( it == "-c" )
  ## @descr Sequence of words is a binary if the `-c` switch is not included in them (not active)
func notBinary *(line :seq[string]) :bool=  not line.isBinary()
  ## @descr Sequence of words cannot be a binary line. The `-c` switch disables linking.
#___________________
func isAssembler *(line :seq[string]) :bool=
  ## @descr Lines that contain `-x assembler-with-cpp` always define an assembler compilation step.
  for id,word in line.pairs:
    if word == "-x" and line[id+1].isAsmLang(): return true  # TODO: alternative --language switches
func isAssembler *(trg :CTarget) :bool=  trg.flags.toSeq.isAssembler()
  ## @descr CTargets that contain `-x assembler-with-cpp` in their flags always define an assembler compilation step
func isAssembler *(trg :FinalTarget) :bool=
  ## @descr FinalTarget that contain `-x assembler-with-cpp` in their flags always define an assembler compilation step
  for src in trg.src:
    if src.flags.toSeq.isAssembler(): return true
  for glob in trg.globs:
    if glob.cflags.toSeq.isAssembler(): return true
  for excp in trg.excepts:
    if excp.cflags.toSeq.isAssembler(): return true
#___________________
func isObj *(line :seq[string]) :bool=
  ## @descr Lines cannot be objects when they build a binary target, or their output is not a known obj file.
  if line.isBinary(): return false  # Cannot be object if it builds a binary
  return line.getTrg.string.isObj()
#___________________
func isRoot *(line :seq[string]) :bool= not line.isObj()
  ## @descr Lines that are not intermediate objects are considered roots
#_______________________________________
func findOutput *(words :seq[string]) :string=
  ## @descr Returns the output of the given line:(seq[word]) by finding -o and returning the next entry.
  for id,word in words.pairs:
    if word == "-o": return words[id+1]
#_______________________________________
func isDynLib *(words :seq[string]) :bool=  words.anyIt( it.startsWith("-shared") or it.startsWith("-dynamiclib") )
  ## @descr Sequence of words is a dynamic library line when the `-shared` flag is passed for linking.
func isStaticLib *(words :seq[string]) :bool=  words.anyIt( it.startsWith("-static") )
  ## @descr Sequence of words is a static library line when the `-shared` flag is passed for linking.
func isApp *(words :seq[string]) :bool=  not (words.isDynLib or words.isStaticLib)
  ## @descr Sequence of words is an Application line when it is not a dynamic or static lib.
#_______________________________________
func isDynLib *(line :string) :bool=  line.splitWhitespace().isDynLib()
  ## @descr Line is a dynamic library when the `-shared` flag is passed for linking.
func isStaticLib *(line :string) :bool=  line.splitWhitespace().isStaticLib()
  ## @descr Line is a static library when the `-shared` flag is passed for linking.
func isApp *(line :string) :bool=  not (line.isDynLib or line.isStaticLib)
  ## @descr Line is an Application when it is not a dynamic or static lib.
func notBinary *(line :string) :bool=  line.splitWhitespace().anyIt( it == "-c" )
  ## @descr Cannot be binary. The `-c` switch disables linking.
#_______________________________________
proc globDir *(dir :Path; root :Path= "".Path) :seq[Path]=
  ## @descr Returns a list of all files/folders contained in {@arg dir} with a path relative to {@arg root}
  let folder = if root != "".Path: root/dir else: dir
  for file in folder.walkDir():
    if file.path.string.isSrc(): result.add file.path
#_______________________________________
func isDirect *(trg :RootTarget) :bool=  trg.deps.len == 0
  ## @descr
  ##  Returns true if the target is a Direct compilation target, without intermediate objects.
  ##  Root targets are considered Direct if they have no `deps`, no matter what their `src` contents are.

