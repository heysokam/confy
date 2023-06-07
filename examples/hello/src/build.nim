import confy

let srcCore = srcDir.glob()
let srcSub  = glob srcDir/"sub"
var bin = Program.new(
  src = srcCore & srcSub,
  trg = "hello-x64",
)

bin.build()

