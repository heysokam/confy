import confy

let srcHello = srcDir/"hello.nim"
var hello = Program.new(
  src   = srcHello,
  trg   = "hello-nim-x64",
  ) # Doesn't build. Stores the configuration for calling .build() later

#_____________________
# Normal Compilation |
#____________________|
when not defined(CrossCompile):
  hello.syst = confy.getHost()         # This is the default value set when not specified. Explicit just for clarity of the example.
  hello.build( run=true, force=true )  # Order to build. Defaults when omitted: (run=false, force=false)

#_____________________
# Cross Compilation  |
#____________________|
elif defined(CrossCompile): # --d:CrossCompile in the src/build.nim.cfg file to run this part of the example
  # Build the target for Linux x86_64
  var lnx  = hello                                 # Make a copy, so we have the configuration on this target too
  lnx.trg  = hello.trg&"-x64"                      # Give it a unique name (just for clarity)
  lnx.syst = System(os: OS.Linux, cpu: CPU.x86_64) # Change the target to build for Linux and x86_64
  lnx.build()                                      # Order to build, but not run and not forcebuild

  # Build the target for Windows x86_64
  var win  = hello                                   # Make a copy, so we have the configuration on this target too
  win.trg  = hello.trg&".exe"                        # Give it the .exe extension
  win.syst = System(os: OS.Windows, cpu: CPU.x86_64) # Change the target to build for Windows and x86_64
  win.build()                                        # Order to build, but not run and not forcebuild

  # Build the target for mac.x64
  var macx64  = hello                               # Make a copy, so we have the configuration on this target too
  macx64.trg  = hello.trg&".app"                    # Give it the .app extension
  macx64.syst = System(os: OS.Mac, cpu: CPU.x86_64) # Change the target to build for Mac and x86_64
  macx64.build()                                    # Order to build, but not run and not forcebuild

  # Build the target for mac.arm64
  var macarm  = hello                              # Make a copy, so we have the configuration on this target too
  macarm.trg  = hello.trg&".app"                   # Give it the .app extension
  macarm.syst = System(os: OS.Mac, cpu: CPU.arm64) # Change the target to build for Mac and arm64
  macarm.build()                                   # Order to build, but not run and not forcebuild

