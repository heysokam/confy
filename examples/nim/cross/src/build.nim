import confy

#____________________________________________________
# Build Target Configuration
#_____________________________
var full = Program.new(           # Configure the target options common to all systems
  src     = srcDir/"hello.nim",   # Must be specific for each build target
  trg     = "full-nim",           # Must be specific for each build target
  cc      = Zig,
  flags   = cfg.flags(C),
  syst    = confy.getHost(),
  root    = cfg.binDir,
  sub     = Dir(""),
  remotes = @[],                  # Does nothing for Nim
  version = "",
  args    = "",                   # Extra Arguments to send to the Nim compiler
  ) # Doesn't build. Stores the configuration for calling .build() later


#_____________________________
# Comment this line to disable cross-compilation
# @note Only for ergonomics.
#  You can control this define however you prefer.
#  `-d:CrossCompile` also works.
#  And the same if you change the name of this to something else.
{.define: CrossCompile.}
#_____________________________


#_____________________
# Normal Compilation |
#____________________|
when not defined(CrossCompile):
  full.syst = confy.getHost()         # This is the default value set when not specified. Explicit just for clarity of the example.
  full.build( run=true, force=true )  # Order to build. Defaults when omitted: (run=false, force=false)

#_____________________
# Cross Compilation  |
#____________________|
elif defined(CrossCompile):
  # Build the target for Linux x86_64
  var lnx  = full
  lnx.trg  = Path full.trg.string&"-x64"
  lnx.syst = System(os: OS.Linux, cpu: CPU.x86_64)
  lnx.build( run=false, force=false )

  # Build the target for Windows x86_64
  var win  = full
  win.trg  = Path full.trg.string&".exe"
  win.syst = System(os: OS.Windows, cpu: CPU.x86_64)
  win.build( run=false, force=false )

  # Build the target for mac.x64
  var macx64  = full
  macx64.trg  = Path full.trg.string&"-x64.app"
  macx64.syst = System(os: OS.Mac, cpu: CPU.x86_64)
  macx64.build( run=false, force=false )

  # Build the target for mac.arm64
  var macarm  = full
  macarm.trg  = Path full.trg.string&"-arm.app"
  macarm.syst = System(os: OS.Mac, cpu: CPU.arm64)
  macarm.build( run=false, force=false )
