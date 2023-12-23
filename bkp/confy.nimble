skipFiles           = @["nim.cfg"]

#_________________________________________________
# Run the example demo projects
#___________________
before helloC: echo packageName,": This is happening before helloC.task."
after  helloC: echo packageName,": This is happening after helloC.task."
task helloC, "Example C:  Executes confy inside the helloC folder":
  withDir helloDir: exec "nim hello.nims"
#___________________
task helloNim, "Example Nim:  Executes confy inside the nim_hello folder":
  withDir helloNimDir: exec "nimble confy"
task helloNimFull, "Example Nim (Full):  Executes confy inside the nim_full folder":
  withDir helloNimFullDir: exec "nimble confy"
