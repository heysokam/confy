#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
{.error:"Tasks and keywords need to be reimplemented for the refactor of 2.0.0".}
# std dependencies
import std/strutils
# confy dependencies
import ../cfg

#_______________________________________
# Examples
#___________________
template example *(name :untyped; descr,file :static string; deps :seq[string]; argl :seq[string]= @[]; runv=true; forcev=false)=
  ## Generates a BuildTrg to build+run the given example.
  ## The example will be built either when its keyword `name` or when the `examples` keyword are sent.
  ## All dependencies in `deps` will be installed before.
  let prevSrcDir = cfg.srcDir
  let sname  = astToStr(name)  # string name
  cfg.srcDir = cfg.examplesDir
  var `name` = Program.new(
    src  = cfg.examplesDir.string/file,
    trg  = sname,
    args = argl.join(" "),
    ) # Program.new( ... )
  if defined(nimble): # skip installing dependencies for non-nimble setups
    for dep in deps: require dep
  `name`.build(@["examples"], run=`runv`, force=`forcev`)
  cfg.srcDir = prevSrcDir
