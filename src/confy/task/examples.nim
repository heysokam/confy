#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# confy dependencies
import ../cfg

#_______________________________________
# Examples
#___________________
template example *(name :untyped; descr,file :static string; deps :seq[string]; runv=true; forcev=false)=
  ## Generates a BuildTrg to build+run the given example.
  ## The example will be built either when its keyword `name` or when the `examples` keyword are sent.
  ## All dependencies in `deps` will be installed before.
  let prevSrcDir = cfg.srcDir
  let sname  = astToStr(name)  # string name
  cfg.srcDir = cfg.examplesDir
  var `name` = Program.new(cfg.examplesDir.string/file, sname)
  for dep in deps: require dep
  `name`.build(@["examples", sname], run=`runv`, force=`forcev`)
  cfg.srcDir = prevSrcDir



