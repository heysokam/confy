import * as B from '@heysokam/confy'
const hello = new B.Program("./src/hello.c")
hello.build().run()
