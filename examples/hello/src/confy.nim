import pkg/confy

let bin = Program.new(
  src = @["hello.c"],
  trg = "hello.x64",
)

bin.build()

