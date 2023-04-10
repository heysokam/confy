import pkg/confy

var bin = Program.new(
  src = srcDir.glob(),
  trg = "hello.x64",
)

bin.build()

