#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# Make Command Parsing                        |
# from pretend cli command `make keyword -n`  |
#_____________________________________________|
# std dependencies
import std/os except `/`
import std/paths
import std/strformat
import std/strutils
import std/sequtils
import std/enumutils
# confy dependencies
import ../../types
import ../../cfg
import ../../tool/logger
import ../../tool/helper
import ../../builder/zig


type Lines * = object
  cc*, info*, mk*, loop*, mkdirs*, clean*, wrn* :seq[string]
  id *:int
func isCC    (line :string) :bool=  line.startsWith("cc") or line.startsWith("gcc") or "q3lcc" in line or "stringify" in line or "q3asm" in line or "lburg" in line
func isMake  (line :string) :bool=  line.startsWith("make") or line.startsWith("cat")
func isMkDir (line :string) :bool=  line.startsWith("if [ ! -d") or line.startsWith("mkdir") or "mkdir" in line
func isClean (line :string) :bool=  line.startsWith("rm")
func isInfo  (line :string) :bool=  line.startsWith("echo") or line.startsWith("\techo") or line.startsWith("Entering")
func isLoop  (line :string) :bool=  line.startsWith("for") or line.startsWith("do") or line.startsWith("done")
proc isWrn   (line :string) :bool=
  line.startsWith("\t-l") or line.startsWith("\t -l") or line.startsWith("\t\t-l") or line.startsWith("\t-o") or line.startsWith("  ")
proc isEmpty (line :string) :bool=  line == "\t\n" or line == "\t\t\n" or line == "  \n" or line == "\n" or line == ""
proc toLines *(cli :string) :Lines=
  log "Parsing the pretend command output ..."
  var other   :seq[string]
  var prev    :string
  var addnext :bool
  for id,line in cli.split("\n").pairs():
    var curr = line
    result.id = id
    if " \\" in line:                        # Bash newline with \
      prev = curr; addnext = on; continue    # Skip line and turn on the switch. Will add the next line to the current one instead
    elif addnext:                            # Addition switch is on, and the line doesn't end with \
      curr = prev & curr; addnext = off      # Add the current with the previous, and turn off the switch
    if   curr.isCC:    result.cc.add curr
    elif curr.isInfo:  result.info.add curr
    elif curr.isLoop:  result.loop.add curr
    elif curr.isMake:  result.mk.add curr
    elif curr.isMkDir: result.mkDirs.add curr
    elif curr.isClean: result.clean.add curr
    elif curr.isWrn:   result.wrn.add curr
    elif curr.isEmpty: continue
    else: other.add curr
  if other.len > 0:
    for it in other:
      if it.len == 0: echo "Entry is empty"; continue
      echo case it[0]
      of ' ':  "Starts with WhiteSpace"
      of '\t': "Starts with tab"
      of '\n': "Starts with newl"
      else:    "Starts with something else-> ",it[0]
    gerr "Others should be empty, but it contains ",other.len," elements: \n",other.join("\n")


#_______________________________________
# Objects
#___________________
func toObj (entry :string) :string=  entry.changeFileExt( if defined(windows): ".obj" else: ".o")
  ## Returns the given entry with an obj extension appropriate for the system.
proc isObj (entry :string) :bool=  entry.endsWith(".o") or entry.endsWith(".obj")
  ## Returns true if the given entry is an object file.
proc getObjs (cmdList :seq[string]) :seq[string]=
  ## Gets a list of all objects in the given list of entries.
  for entry in cmdList:
    if entry.isObj: result.add entry
proc isMultiObj (cmdList :seq[string]) :bool=  cmdList.getObjs.len > 1
  ## Returns true if the given list contains multiple object files.
proc hasObjs (cmdList :seq[string]) :bool=  cmdList.getObjs.len > 0
  ## Returns true if the list has at least one object file in it.


#_______________________________________
# Source files
#___________________
proc isSrc (entry :string) :bool=  entry.endsWith(".c") or entry.endsWith(".cc") or entry.endsWith(".cpp")
  ## Returns true if the given entry is a known code file.
proc getCfiles (cmdList :seq[string]) :seq[string]=
  ## Returns a list of all code contained in the given list.
  for entry in cmdList:
    if entry.isSrc: result.add entry
proc hasCfiles (cmdList :seq[string]) :bool=  cmdList.getCfiles.len > 0
  ## Returns true if the given list has at least one code file.


#_______________________________________
# Command parsing
#___________________
# CC Data container
type CC = object
  cmd   :string
  src   :seq[string]
  trg   :string
  defs  :seq[string]
  libs  :seq[string]
  paths :seq[string]  # -L and -I paths
  flags :Flags
  bin   :bool
  obj   :tuple[inp:bool, outp:bool]  ## Whether the commands operates on an object, and is the object input or output.
  debug :string
  optim :string
#___________________
# Parse commands
proc isBin  (cmd :string) :bool=  " -c " in cmd or cmd.split(" ").hasCfiles() or not cmd.split(" ").hasObjs()
proc isLink (cmd :string) :bool=  " -c " notin cmd and not cmd.split(" ").hasCfiles()
proc getSrc (cmd :string) :seq[string]=
  ## Gets the list of source files that are contained in the given command.
  let list = cmd.split(" ")
  if " -c " in cmd:  result = list.getCfiles  # from .c to .o
  else:              result = list.getObjs & list.getCfiles  # from (.c,.o) to bin
proc getTrg (cmd :string) :string=
  ## Gets the build target of the given command entry.
  let list = cmd.split(" ")
  if " -c " notin cmd:
    for id,entry in list.pairs():
      if entry == "-o": return list[id+1]
    if "stringify" in cmd or "lburg" in cmd: return list.getCfiles[^1]
    wrn "Output file for ",cmd," couldn't be found. Returning a.out"; result = "a.out"
  else: # Implicit object. Search for the -c command, and change the file extension to an obj.
    for id,entry in list.pairs():
      if entry == "-c":
        return list[id+1].toObj
#_______________________________________
proc parseCC (cmd :string) :CC=
  ## Returns a CC command from the given string command.
  result.src = cmd.getSrc
  result.trg = cmd.getTrg
  result.bin = false
  result.obj.inp  = result.src.hasObjs()
  result.obj.outp = result.trg.isObj()
  for id,entry in cmd.split(" ").pairs():
    if id == 0: result.cmd = entry
    if entry.startsWith("-"):
      if entry.startsWith( "-c", "-o", "-MMD" ): continue
      if entry.startsWith( "-std", "-D", "-I", "-W", "-f", "-g", "-O", "-l", "-M", "-pipe", "-march", "-mmmx", "-msse" ):
        result.flags.cc.add entry
      elif entry.startsWith( "-L" ): gerr "Interpreting command ",cmd," as a CC command, but it contails -L flags"
      else: gerr "Interpreting CC command ",cmd," hit an entry starting with `-`, but the flag ",entry," is not registered"
      if   entry.startsWith("-l"): result.libs.add entry
      elif "-D" in entry:          result.defs.add entry
      elif "-I" in entry:          result.paths.add entry
      elif "-g" in entry:          result.debug = entry
      elif "-O" in entry:          result.optim = entry
#_______________________________________
proc parseLD (cmd :string) :CC=
  result.src = cmd.getSrc
  result.trg = cmd.getTrg
  result.bin = true
  result.obj.inp  = result.src.hasObjs()
  result.obj.outp = result.trg.isObj()
  for id,entry in cmd.split(" ").pairs():
    if id == 0: result.cmd = entry; continue
    if entry.startsWith("-"):
      if entry.startsWith( "-c", "-o", "-MMD" ): continue
      if entry.startsWith( "-std", "-D", "-I", "-W", "-f", "-g", "-O", "-l", "-pipe", "-rdynamic", "-shared", "-march" ):
        result.flags.ld.add entry
      else: gerr "Interpreting LD command ",cmd," hit an entry starting with `-`, but the flag ",entry," is not registered"
      if   entry.startsWith("-l"): result.libs.add entry
      elif "-D" in entry:          result.defs.add entry
      elif "-I" in entry:          result.paths.add entry
      elif "-L" in entry:          result.paths.add entry
      elif "-g" in entry:          result.debug = entry
      elif "-O" in entry:          result.optim = entry
#_______________________________________
proc parse *(list :Lines) :seq[CC]=
  for id,entry in list.cc.pairs:
    var  res :CC
    if   entry.isMake:  echo "__________________________\n",entry,"__________________________"
    elif entry.isInfo:  continue
    elif entry.isMkDir: continue
    elif entry.isLoop:  continue
    elif entry.isClean: continue
    # elif entry.isWarn:  echo "____WARNING_______________\n",entry,"____________________END___"
    # Important checks last, for dodging some control flow hell issues.
    elif entry.isBin:   result.add entry.parseCC
    elif entry.isLink:  result.add entry.parseLD

#_______________________________________
# CC Command Object : Processing
#___________________
proc getSrc (src :seq[string]) :seq[string]= discard
  ## TODO: The logic of this makes no sense, but seems to work anyway. Something is off, might become clearer through testing.
proc getSrc (cmd :CC) :seq[string]=
  ## Gets a seq of src files from the given command.
  for inner in cmd.src:
    if inner.isObj:
      result &= cmd.src.getSrc
proc getSrc (store :seq[CC]; trg :string) :seq[string]=
  ## Gets a seq of src files from the input list of stored commands.
  for cmd in store:
    if cmd.trg == trg: result &= cmd.src.getCfiles
#___________________
proc mergeSrc (store :seq[CC]) :seq[string]=
  ## Returns the source files contained in the input list of commands, merged together as a single seq.
  for cmd in store:  result &= cmd.src
proc mergeFlags (store :seq[CC]) :Flags=
  ## Returns the Flags contained in the input list of commands, merged together as a single Flags object.
  ## All duplicates will be removed.
  for cmd in store:
    result.cc &= cmd.flags.cc
    result.ld &= cmd.flags.ld
  result.cc = result.cc.deduplicate()
  result.ld = result.ld.deduplicate()
#___________________
# Compiler management
proc getCC (src :seq[string]) :string=  zig.getCC(src)
  ## Gets a Zig compiler command to build the given input list of source files.
  ## Will be `zig c++` if at least one of the files has a known cpp extension.
proc toCompiler *(cmd :string) :Compiler=
  ## Returns the Compiler id of the given command.
  if "zig" in cmd: return Zig
  if "gcc" in cmd or "cc" in cmd or "g++" in cmd: return GCC
  if "clang" in cmd: return Clang
proc toKind (trg :Fil) :BinKind=
  ## Returns the Binary Kind id of the trg file.
  case trg.splitFile.ext
  of ".o", ".obj":            return Object
  of ".a":                    return StaticLibrary
  of ".so", ".dll", ".dylib": return SharedLibrary
  of ".pcm":                  return Module
  of "", ".exe", ".app":      return Program
  else:                       return Program
# id-Tech3 OS/CPU conversions
proc toQuake3 (syst :OS) :string=
  ## Returns the string name used by id-Tech3 buildsystem for the given OS system.
  case syst
  of Mac: result = "darwin"
  else:   result = $syst
proc toQuake3 (arch :CPU) :string=
  ## Returns the string name used by the id-Tech3 buildsystem for the given CPU architecture.
  case arch
  of x86, x86_64: result = arch.symbolName
  else:           result = $arch
proc fromQuake3OS (syst :string) :OS=
  ## Returns the OS id for the given id-Tech3 system name.
  case syst
  of "windows": result = OS.Windows
  of "linux":   result = OS.Linux
  of "darwin":  result = OS.Mac
  else: gerr "Tried to access the OS value for ",syst,", but it is not mapped to any."
proc fromQuake3CPU (arch :string) :CPU=
  ## Returns the CPU id for the given id-Tech3 architecture name.
  case arch:
  of "x86":    result = CPU.x86
  of "x86_64": result = CPU.x86_64
  of "arm":    result = CPU.arm
  else: gerr "Tried to access the CPU value for ",arch,", but it is not mapped to any."
# System id
proc getSystem (trg :string) :System=
  ## Returns the System id of the given trg file.
  ## Will translate to names used by the id-Tech3 buildsystem names when the input doesn't match any.
  for it in OS:
    if $it in trg or it.toQuake3 in trg:  result.os = it
  for it in CPU:
    if $it in trg or it.toQuake3 in trg:  result.cpu = it
proc isRootSub (sub :string; syst :System) :bool=
  ## Returns true if the given subfolder string matches the input System id.
  result = ($syst.os  in sub or syst.os.symbolName  in sub) or
           ($syst.cpu in sub or syst.cpu.symbolName in sub)
proc getRootAndBasename (trg :string; syst :System) :tuple[base:string, root:string]=
  ## Returns the (baseName, rootDir) of the given target string, based on the input System id.
  let subs = trg.split(os.DirSep)
  for id,sub in subs.pairs():
    if sub.isRootSub(syst):
      let baseList = subs[id+1..^1].toSeq
      let rootList = subs[0..id].toSeq
      return (base: baseList.join($os.DirSep), root: rootList.join($os.DirSep))
proc getRoot (trg :string; syst :System) :string=  trg.getRootAndBasename(syst).root
  ## Returns the rootDir of the given target string, based on the given System id.
proc getBase (trg :string; syst :System) :string=  trg.getRootAndBasename(syst).base
  ## Returns the baseName of the given target string, based on the given System id.


#_______________________________________
# CC Command Object : Parse to BuildTrg object.
#___________________
proc toTarget *(cmd :CC) :BuildTrg=
  ## Returns the BuildTrg object for the given CC Command object.
  result.kind  = cmd.trg.toKind
  result.src   = cmd.src
  result.trg   = cmd.trg
  result.cc    = cmd.src.getCC.toCompiler
  result.flags = cmd.flags
  result.syst  = cmd.trg.getSystem
  result.root  = cmd.trg.getRoot(result.syst)
#___________________
proc toTargets *(cmds :var seq[CC]) :seq[BuildTrg]=
  ## Returns a list of BuildTrg objects for the given list of CC Command objects.
  log "Processing the parsed result ..."
  var store :seq[CC]
  for cmd in cmds.mitems:
    if not cmd.bin:
      store.add cmd
    if cmd.bin:
      cmd.src   = store.mergeSrc
      cmd.flags = store.mergeFlags
      store   = @[]
      result.add cmd.toTarget

