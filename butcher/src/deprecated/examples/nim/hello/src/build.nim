import confy

let srcHello = srcDir/"hello.nim"
var hello = Program.new(
  src   = srcHello,
  trg   = "hello-nim-x64",
  ) # Doesn't build. Stores the configuration for calling .build() later

hello.build( run=true )  # Order to build. Defaults when omitted: (run=false, force=false)
