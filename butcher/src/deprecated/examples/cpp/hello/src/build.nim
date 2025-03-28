import confy

let srcCore = srcDir.glob(".cpp")
let srcSub  = glob(srcDir/"sub", ".cpp")
var bin = Program.new(
  src   = srcCore & srcSub,
  trg   = "hello-x64",
  flags = cfg.flags(Cpp),
)

bin.build( @["all"], run=true )

