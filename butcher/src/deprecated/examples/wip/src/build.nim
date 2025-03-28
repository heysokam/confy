import ../../../src/confy

#____________________________________________________
# Confy Global Configuration
#_____________________________
# Explicit list of defaults
cfg.verbose         = off
cfg.quiet           = on
cfg.zigSystemBin    = off  # default: on    (off) means we auto-download zigcc for this project. (on) means the user has zigcc already installed in PATH
cfg.fakeRun         = off


#____________________________________________________
# Build Target Configuration
#_____________________________
var wip = Program.new(
  src     = srcDir/"hello.nim",
  trg     = "wip-nim",
  flags   = cfg.flagsC,
  sub     = Dir("nimwip"),
  args    = "",
  ) # << Program.new( ... )
wip.build( keywords = @["wip"], run=true, force=false )  # Order to build. Defaults when omitted: (@[], run=false, force=false)

#________________________________________
# Examples tasks
#___________________
template example (name :untyped; descr,file :static string)=
  ## Custom examples alias definition  (specific per project)
  let deps = @["vmath"]
  example name, descr, file, deps, true, true
#___________________
# Build the examples binaries
example hello, "Example 00: confy.example.", "e00_hello"
