import * as B from 'confy'
const hello = new B.Program("./src/hello.c")
hello.build().run()
