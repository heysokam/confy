#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
# Code File generation  |
#_______________________|
# std dependencies
import std/os except `/`
import std/paths
import std/strformat
import std/strutils
import std/enumutils
import std/tables
import std/sets
# confy dependencies
import ../../types
import ../../tool/logger
# Module dependencies
import ../types as convT
import ./parse


#___________________
const Separator = "\n\n\n"  ## Separator format used between entries.
const Footer    = "\n"      ## Footer added to the resulting file.
const Header    = """
#________________________________
# AutoGenerated | Make-to-Confy  |
#_________________________________________________________________________________
# This file is generated by the makefile-to-confy converter.                     |
# The tool parses the output of the pretend command `make keyword -n`,           |
# and generates the structure of this file.                                      |
# `echo`, `mkdir` and `rm` commands are completely ignored.                      |
# Files are listed explicitely, even if the makefile includes them from a glob.  |
#________________________________________________________________________________|
# std dependencies
from std/os import `/`
# confy dependencies
import confy
"""
const CodeTemplate = """
#_______________________________________
# {trgName}: Setup
#_____________________________
let {trgName}Bin  = "{trg.trg.string}"
let {trgName}Root = "{trg.root.string}"
let {trgName}Src  = {trgSrc}
var {trgName}Trg  = {trg.kind}.new(
  src   = {trgName}Src,
  trg   = {trgName}Bin,
  cc    = {$trg.cc},
  flags = Flags(
    cc: {trgCFlags}
    ld: {trgLFlags}
    ), # << {trgName}.Flags( ... )
  root = {trgName}Root,
  syst = System(os: OS.{trg.syst.os.symbolName}, cpu: CPU.{trg.syst.cpu.symbolName}),
  ) # << {trgName}.new({trg.kind}, ... )
#_____________________________
# {trgName}: Task
{trgName&"Trg"}.build()
#___________________
"""
#___________________
proc toFormat (list :seq[Path | string]; name,field :string; level :SomeInteger= 1) :string=
  ## Returns a formatted string for the given list of src files.
  var tab :string
  for lvl in 0..<level: tab.add "  "
  result.add $"@[\n" & tab
  for file in list:
    if file.string == "": continue
    result.add &"\"{file.string}\",\n{tab}"
  result.add &"] # << {name}.{field}( ... )\n"


#___________________
proc toCode *(trg :BuildTrg; name :string) :string=
  ## Returns the code string entry for a single BuildTrg object.
  let trgName   = name
  var trgSrc    = trg.src.toFormat(name,"src", 1)
  var trgCFlags = trg.flags.cc.toFormat(name,"Flags.cc", 3) & ","
  var trgLFlags = trg.flags.ld.toFormat(name,"Flags.ld", 3) & ","
  result = fmt( CodeTemplate )
  result = result.replace( &"\"build{os.DirSep}", &"binDir/\"" )
  result = result.replace( &"\"code{os.DirSep}",  &"srcDir/\"" )

#___________________
proc toFile *(trg :BuildTrg; file :Fil; name :string) :void=
  ## Writes the formatted code string of the input BuildTrg object into the given file path.
  log &"Writing code from `{name}` into `{file.string}` ..."
  file.writeFile( Header & Separator & trg.toCode(name) & Footer )
#___________________
proc toFile *(trgs :seq[BuildTrg]; file :Fil; name :string) :void=
  ## Writes the formatted code string of the input list of BuildTrg objects into the given file path.
  log &"Writing code from `{name}` into `{file.string}` ..."
  var code = Header
  for id,trg in trgs.pairs:
    code &= Separator & trg.toCode( name & &"{id:002}" )
  code &= Footer
  file.writeFile( code )


#_______________________________________
proc toDirsTable (target :BuildTrg; root :Dir= ""; dbg=off) :DirsTable=
  for file in target.src:
    let dir = file.splitFile.dir
    if not result.hasKey(dir): result[dir] = initHashSet[Dir]()
    result[dir].incl root/file
  if dbg:
    echo &"\n__{target.trg}_____________________"
    for dir,code in result.pairs: echo &":: Folder {dir} contains :\n", code

#_____________________________
proc toGlobsTable (target :BuildTrg; root :Dir= ""; dbg=off) :GlobsTable=
  for src in target.src:
    let dir = src.splitFile.dir
    if not result.hasKey(dir): result[dir] = initHashSet[Src]()
    for file in walkPattern( root/dir/"*.c" ):
      result[dir].incl file
  if dbg:
    echo &"\n__{target.trg}_______________________"
    for dir,code in result.pairs: echo &":: Globbed file list for folder {dir} contains :\n", code, "\n"

#_____________________________
proc getTrees (targets :seq[BuildTrg]; root :Dir= ""; dbg=off) :seq[CodeTree]=
  ## Create a set of target trees. Each file associated with their requires dirs+files
  for target in targets:
    result.add CodeTree(
      trg  : target.trg,
      code : target.toDirsTable( root=root, dbg=dbg ),
      ) # << CodeTree( ... )
#_____________________________
proc getGlobs (targets :seq[BuildTrg]; root :Dir= ""; dbg=off) :seq[GlobTree]=
  ## Creates a set of code trees, globbed from the folders used to build the given targets
  for target in targets:
    result.add GlobTree(  # alias for CodeTree
      trg  : target.trg,
      code : target.toGlobsTable( root=root, dbg=dbg ),
      ) # << CodeTree( ... )
#_____________________________
proc difference (glob :GlobTree; code :CodeTree; dbg=off) :DiffTree=
  ## Returns a filter remove, created from the difference of code sets contained in the input trees.
  if glob.trg != code.trg: raise newException(IOError, "Tried to get the difference of two targets that are not the same.\n    " & glob.trg & " <> " & code.trg)
  result.trg  = code.trg
  for dir,files in glob.code.pairs:
    if not result.code.hasKey(dir): result.code[dir] = initHashSet[Src]()
    result.code[dir] = glob.code[dir] - code.code[dir]
  if dbg:
    for dir1,files1 in glob.code.pairs:
      for dir2,files2 in code.code.pairs:
        if dir1 != dir2: continue
        echo "--------------------------------------"
        echo "Target: ",glob.trg
        echo "\nFiles1: ",files1
        echo "\nFiles2: ",files2
        echo "\nDiffr:  ",files1-files2
#_____________________________
template `-` (glob :GlobTree; code :CodeTree) :DiffTree=  glob.difference(code)
  ## Returns a code tree containing only the difference between the input glob and code.
#_____________________________
proc getDifferences (globs :seq[GlobTree]; codes :seq[CodeTree]) :seq[DiffTree]=
  ## Returns a list of code Trees containing only the difference between the input lists of globs and code trees.
  for glob in globs:
    for code in codes:
      if glob.trg != code.trg: continue
      result.add( glob - code )

#_______________________________________
proc getSources *(targets :seq[BuildTrg]; root :Dir= ""; dbg=off) :BuildCode=
  ## Returns a tuple of the lists of (trees, globs, filters) associated with the given list of Build Targets.
  ## Corrects the code to be relative to `root` when not omitted.
  result.trees = targets.getTrees( root=root, dbg=dbg )
  result.globs = targets.getGlobs( root=root, dbg=dbg ) 
  result.diffs = getDifferences( result.globs, result.trees ) 

#_______________________________________
const GlobSrcHeader   = "import ./dir\n\n"
const GlobDirTemplate = "let {name} * = {rootpath}\"{dir}\"\n"
const GlobSrcTemplate = "let {name} * = dir.{name}.glob\n"
proc toStringSet (glob :GlobTree; root :Dir= "") :tuple[src:HashSet[string], dir:HashSet[string]]=
  ## Formats the given glob tree into its relevant confy/Nim code.
  ## Corrects the code to be relative to `root` when not omitted.
  let rootpath = if root.string != "": &"{root}/" else: root
  for dir in glob.code.keys:
    let name = dir.lastPathPart
    result.src.incl fmt( GlobSrcTemplate )
    result.dir.incl fmt( GlobDirTemplate )
#_______________________________________
proc toString *(globs :seq[GlobTree]; root :Dir= "") :tuple[src:string, dir:string]=
  ## Formats the given list of globs into its relevant confy/Nim code.
  ## Returns separate code for the src and dir files.
  ## Corrects the code to be relative to `root` when not omitted.
  var srcSet :HashSet[string]
  var dirSet :HashSet[string]
  result.src.add GlobSrcHeader
  for glob in globs:
    let code = glob.toStringSet(root)
    srcSet = srcSet + code.src
    dirSet = dirSet + code.dir
  for dir in dirSet: result.dir.add dir
  for src in srcSet: result.src.add src

#_______________________________________
const DiffTemplate = "let {name}Diff * = {diffString}\n"
const TreeTemplate = "let {name}Code * = {codeString}\n"
#_______________________________________
proc toStringSeq (diff :DiffTree; root :Dir= "") :seq[string]=
  ## Formats the given diffs tree into its relevant confy/Nim code.
  ## Corrects the code to be relative to `root` when not omitted.
  let rootpath = if root.string != "": &"{root}/" else: root
  result.add &"#_____________________________________\n# Diff filters for target:  {diff.trg}\n"
  for dir,code in diff.code.pairs:
    let name = dir.lastPathPart
    var diffString = "@[ "
    for file in code:  diffString.add &"\"{rootpath}{file}\", "
    diffString.add " ]"
    result.add fmt( DiffTemplate )
#_______________________________________
proc toStringSeq (tree :CodeTree; root :Dir= "") :seq[string]=
  ## Formats the given code tree into its relevant confy/Nim code.
  ## Corrects the code to be relative to `root` when not omitted.
  let rootpath = if root.string != "": &"{root}/" else: root
  result.add &"#_____________________________________\n# Code for target:  {tree.trg}\n"
  for dir,code in tree.code.pairs:
    let name = dir.lastPathPart
    var codeString = "@[ "
    for file in code:  codeString.add &"\"{rootpath}{file}\", "
    codeString.add "]"
    result.add fmt( TreeTemplate )
#_______________________________________
proc toString *(diffs :seq[DiffTree]; trees :seq[CodeTree]; root :Dir= "") :string=
  ## Returns the given list of diffs and codetrees, converted into their correct buildcode.
  ## Corrects the code to be relative to `root` when not omitted.
  var diffSeq :seq[string]
  var codeSeq :seq[string]
  for diff in diffs: diffSeq &= diff.toStringSeq(root)
  for tree in trees: codeSeq &= tree.toStringSeq(root)
  for diff in diffSeq: result.add diff  #& "\n"
  result.add "\n\n#_______________________________________________________________________\n"
  for tree in codeSeq: result.add tree  #& "\n"

