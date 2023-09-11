#____________________________________________________
# All options listed in this example are running the already existing pre-defined defaults
# This file does not change anything  (unless explicitely specified in a comment right next to the change)
#____________________________________________________
# Dependencies Already imported by confy.
# Don't add them, only required if you are changing any of the defaults by using the same dependencies
import std/cpuinfo       # Only for the example.
import std/os except `/` # Only for the example.
import std/strformat     # Only for the example.
#_____________________________
# Builld.nim starts here:

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
cfg.zigSystemBin    = off  # default: on    (off) means we auto-download zigcc for this project. (on) means the user has zigcc already installed in PATH
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
cfg.file            = "build.nim"
cfg.db              = binDir/".confy.db"
cfg.zigJson         = binDir/".zig.json"
let switchVerbose   = if cfg.verbose: "--verbose"     else: ""  # Already declared internally as a private variable. Redeclaring for clarity
let switchVerbosity = if cfg.verbose: "--verbosity:2" else: ""  # Already declared internally as a private variable. Redeclaring for clarity
cfg.nimble          = &"nimble {switchVerbose}"
cfg.nimc            = &"nim c {switchVerbosity} -d:release"
cfg.flagsC          = confy.allC
cfg.flags           = confy.allPP


#____________________________________________________
# Build Target Configuration
#_____________________________
var full = Program.new(           # Configure the target options common to all systems
  src     = srcDir/"hello.nim",   # Must be specific for each build target
  trg     = "full-nim",           # Must be specific for each build target
  cc      = Zig,
  flags   = cfg.flags,
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
when not defined(CrossCompile):
  full.syst = confy.getHost()         # This is the default value set when not specified. Explicit just for clarity of the example.
  full.build( run=true, force=true )  # Order to build. Defaults when omitted: (run=false, force=false)

#_____________________
# Cross Compilation  |
#____________________|
elif defined(CrossCompile):
  # Build the target for Linux x86_64
  var lnx  = full
  lnx.trg  = full.trg&"-x64"
  lnx.syst = System(os: OS.Linux, cpu: CPU.x86_64)
  lnx.build( run=false, force=false )

  # Build the target for Windows x86_64
  var win  = full
  win.trg  = full.trg&".exe"
  win.syst = System(os: OS.Windows, cpu: CPU.x86_64)
  win.build( run=false, force=false )

  # Build the target for mac.x64
  var macx64  = full
  macx64.trg  = full.trg&".app"
  macx64.syst = System(os: OS.Mac, cpu: CPU.x86_64)
  macx64.build( run=false, force=false )

  # Build the target for mac.arm64
  var macarm  = full
  macarm.trg  = full.trg&".app"
  macarm.syst = System(os: OS.Mac, cpu: CPU.arm64)
  macarm.build( run=false, force=false )













##[ TODO ]#____________________________________________________



# std dependencies
import std/sets
func getKeywordList *(cli :CLI) :OrderedSet[string]=
  debugEcho cli
var keywordList :OrderedSet[string]=  getCLI().getKeywordList()

template requires *(name,dep :string) :void= discard

#________________________________________
# Build tasks
#___________________
template example *(name :untyped; descr,file :static string; deps :seq[string]; run=true; force=false)=
  ## Generates a task to build+run the given example
  let sname = astToStr(name)  # string name
  for dep in deps: requires sname, dep
  var `name` = Program.new(cfg.examplesDir/file, file)
  if sname in keywordList: `name`.build(`run`=run, `force`=force)

template example *(name :untyped; descr,file :static string)=
  ## Custom examples alias (per project)
  example name, descr, file, newSeq[string](), true, true

example hello, "Example 00:  hellowindow.", "e00_hellowgpu"

#___________________
keyword "nc", "Builds+Run the current nim project, using confy.", package.name
keyword "ex", "Builds+Run the example app, using confy.", "wgpu"/"example"
# Build the examples binaries
example wip,       "Example WIP: Builds the current wip example.",  "wip"
example clear,     "Example 01:  helloclear.",                      "e01_helloclear"
example triangle,  "Example 02:  hellotriangle.",                   "e02_hellotriangle"
example buffer,    "Example 03:  hellobuffer.",                     "e03_hellobuffer"
example compute,   "Example 04:  hellocompute.",                    "e04_hellocompute"
example triangle2, "Example 05:  simple buffered triangle.",        "e05_trianglebuffered1"
example triangle3, "Example 06:  multi-buffered triangle.",         "e06_trianglebuffered2"
example triangle4, "Example 07:  indexed multi-buffered triangle.", "e07_trianglebuffered3"
example uniform,   "Example 08:  single uniform.",                  "e08_hellouniform"
example struct,    "Example 09:  uniform struct.",                  "e09_uniformstruct"
# example dynamic,   "Example 10:  uniform struct.",                  "e10_dynamicuniform"
example texture,   "Example 11:  simple byte texture.",             "e11_hellotexture"
example texture2,  "Example 12:  sampled byte texture.",            "e12_sampledtexture"
example depth,     "Example 13:  simple depth buffer attachment.",  "e13_hellodepth"
example camera,    "Example 14:  simple 3D camera controller.",     "e14_hellocamera"
example uvs,       "Example 15:  cube textured using its UVs.",     "e15_cubetextured"
example instance,  "Example 16:  cube instanced 100 times.",        "e16_cubeinstanced"
example multimesh, "Example 17:  multi-mesh. cubes + pyramid.",     "e17_multimesh"
#___________________
# Build the demo apps
task app1, "App 01: Builds the Framebuffer app.": runExample "app_framebuffer"
#___________________
# Reference Task
task lib, "Reference-only: Builds the wgpu-native library in both release and debug modes":
  # Note: This is automatically done by the buildsystem, without running this task. Only here for reference.
  exec "nimble git"
  withDir wgpuDir:
    exec "make lib-native"
    exec "make lib-native-release"
    # Fix the static linking mess of clang+mac
    when defined(macosx):
      let rlsDir = "./target/release"
      let dbgDir = "./target/debug"
      let file   = "libwgpu_native.a"
      if fileExists( rlsDir/file ):  cpFile rlsDir/file, rlsDir/"libwgpu_native_static.a"
      if fileExists( dbgDir/file ):  cpFile dbgDir/file, dbgDir/"libwgpu_native_static.a"
]##
