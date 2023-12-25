import confy

#____________________________________________________
# Build Target Configuration
#_____________________________
let srcSub  = glob srcDir/"sub"
let srcCore = srcDir.glob()
var cross = Program.new(           # Configure the target options common to all systems
  src     = srcCore & srcSub,
  trg     = "cross-C",             # Must be specific for each build target
  cc      = Zig,
  flags   = cfg.flags(C),
  syst    = confy.getHost(),
  root    = cfg.binDir,
  sub     = Dir(""),
  remotes = @[],                  # Does nothing for Nim
  version = "",
  args    = "",                   # Extra Arguments to send to the compiler
  ) # Doesn't build. Stores the configuration for calling .build() later


#_____________________________
# @note Not required. Only for ergonomics.
#  Comment this line to disable cross-compilation
#  You can control this define however you prefer.
#  `-d:CrossCompile` also works.
#  And the same if you change the name of this to something else.
#  You can also not have this at all and use keywords or target names instead.
{.define: CrossCompile.}
#_____________________________


#_____________________
# Normal Compilation |
#____________________|
when not defined(CrossCompile):
  cross.syst = confy.getHost()         # This is the default value set when not specified. Explicit just for clarity of the example.
  cross.build( run=true, force=true )  # Order to build. Defaults when omitted: (run=false, force=false)

#_____________________
# Cross Compilation  |
#____________________|
elif defined(CrossCompile):
  # Build the target for Linux x86_64
  var lnx  = cross
  lnx.trg  = Path cross.trg.string&"-x64"
  lnx.syst = System(os: OS.Linux, cpu: CPU.x86_64)
  lnx.build( run=false, force=false )

  # Build the target for Windows x86_64
  var win  = cross
  win.trg  = cross.trg
  win.syst = System(os: OS.Windows, cpu: CPU.x86_64)
  win.build( run=false, force=false )

  # Build the target for mac.x64
  var macx64  = cross
  macx64.trg  = Path cross.trg.string&"-x64"
  macx64.syst = System(os: OS.Mac, cpu: CPU.x86_64)
  macx64.build( run=false, force=false )

  # Build the target for mac.arm64
  var macarm  = cross
  macarm.trg  = Path cross.trg.string&"-arm"
  macarm.syst = System(os: OS.Mac, cpu: CPU.arm64)
  macarm.build( run=false, force=false )
