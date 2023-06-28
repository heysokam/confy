import confy

let srcHello = srcDir/"hello.nim"
var bin = Program.new(
  src   = srcHello,
  trg   = "hello-nim-x64",
)

bin.build( run=true )


#_____________________
# Cross Compilation  |
#____________________|
# Build the same target for Windows
bin.trg  = "hello-nim-x64.exe"
bin.syst = System(os: OS.Windows, cpu: CPU.x86_64)
bin.build()

# Build the same target for mac.x64
bin.trg  = "hello-nim-x64.app"
bin.syst = System(os: OS.Mac, cpu: CPU.x86_64)
bin.build()

# Build the same target for mac.arm64
bin.trg  = "hello-nim-arm64.app"
bin.syst = System(os: OS.Mac, cpu: CPU.arm64)
bin.build()

