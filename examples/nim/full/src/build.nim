#____________________________________________________
# All options listed in this example are running the already existing pre-defined defaults
# This file does not change anything  (unless explicitely specified in a comment right next to the change)
#____________________________________________________
# Dependencies Already imported by confy.
# Don't add them, only required if you are changing any of the defaults by using the same dependencies
import std/cpuinfo   # Only for the example.
import std/os        # Only for the example.
import std/strformat # Only for the example.
#_____________________________
# Build.nim starts here:

#____________________________________________________
import confy


#____________________________________________________
# Confy Global Configuration
#_____________________________
# Explicit list of defaults
cfg.cores           = (0.8 * cpuinfo.countProcessors().float).int
cfg.verbose         = off
cfg.quiet           = on
cfg.prefix          = "confy: "
cfg.tab             = "     : "
cfg.Cstr            = "CC"
cfg.Lstr            = "LD"
cfg.zigcc.systemBin = off  # default: on    (off) means we auto-download zigcc for this project. (on) means the user has zigcc already installed in PATH
cfg.fakeRun         = off
cfg.rootDir         = Dir( os.getAppDir()/".." )
cfg.srcDir          = rootDir/"src"
cfg.binDir          = rootDir/"bin"
cfg.libDir          = rootDir/"lib"
cfg.docDir          = rootDir/"doc"
cfg.examplesDir     = rootDir/"examples"
cfg.testsDir        = rootDir/"tests"
cfg.cacheDir        = binDir/".cache"
cfg.zigDir          = binDir/"zig"
cfg.file            = Path( "build.nim" )
cfg.zigJson         = binDir/".zig.json"
cfg.flagsC          = cfg.flags( C   )
cfg.flagsCpp        = cfg.flags( Cpp )


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

#_____________________
# Normal Compilation |
#____________________|
{.define: CrossCompile.}
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
