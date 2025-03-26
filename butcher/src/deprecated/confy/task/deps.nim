#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
from std/sets import HashSet, incl, items, len, toHashSet
from std/sequtils import toSeq
# @deps nstd
from nstd/shell import withDir
import nstd/strings
import nstd/paths
# @deps confy
from ../cfg import nil
import ../types
import ../tool/helper
import ../tool/logger


#_________________________________________________
# @section Nim and Dependency Management
#_____________________________
proc nim (opts :varargs[string,`$`]) :void=
  let cmd = nimGetRealBin().string&" "&opts.join(" ")
  dbg "Running nim with command:\n  ",cmd
  sh cmd, cfg.verbose
proc nimc (opts :varargs[string,`$`]) :void=
  if not fileExists(cfg.binDir/".gitignore"): writeFile(cfg.binDir/".gitignore", "*\n!.gitignore")
  let paths :string= if deps.len > 0: "--path:" & deps.toSeq.join(" --path:") else: ""
  nim &"c --outDir:{cfg.binDir} {paths} "&opts.join(" ")

#_________________________________________________
# @section Dependency Management
#_____________________________
func new *(_:typedesc[Dependencies]; deps :varargs[Dependency]) :Dependencies=  deps.toSeq.toHashSet
  ## @descr Creates a new set of {@type Dependencies} from the given {@arg deps} dependencies list.
#___________________
func to *(dep :Dependency; lang :Lang) :string=
  ## @descr Returns a string with the given {@arg dep} dependency converted to the format understood by the compiler of the given {@arg lang}.
  case lang
  of Nim : "--path:"&dep.dir.string
  else:""
func to *(deps :Dependencies; lang :Lang) :string=
  ## @descr Returns a string with the given {@arg deps} dependencies converted to the format understood by the compiler of the given {@arg lang}.
  case lang
  of Nim:
    for dep in deps: result.add " "&dep.to(lang)
  else: result = ""
#___________________
proc submodule *(name :string; url :string= ""; code :Dir|string= cfg.srcSub; shallow :bool= true) :Dependency {.discardable.}=
  ## @descr Installs the given dependency as a submodule for the project
  result = Dependency(
    name : name,
    url  : url,
    src  : when code is string: code.Path else: code,
    dir  : absolutePath( cfg.libDir/name/code )
    ) # << Dependency( ... )
  if not dirExists(cfg.libDir)               : md cfg.libDir
  if not fileExists(cfg.libDir/".gitignore") : writeFile(cfg.libDir/".gitignore", "*\n!.gitignore")
  if not dirExists(cfg.libDir/name)          : git "clone", &"{url} {cfg.libDir/name}", if shallow: " --depth 1" else: ""

