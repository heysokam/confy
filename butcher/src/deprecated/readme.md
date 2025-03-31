
Minimal build file:
```nim
import confy

let code = srcDir.glob()   # Get our source by grabbing all code from the `srcDir` folder
var bin  = Program.new(    # Build an executable program
  src = code,              # Define our source code
  trg = "hello.exe",       # Define our binary
)

bin.build()                # Order to build
```

## How to Use
There is a full **how-to** guide @[doc/howto](./doc/howto.md)  
See also the [examples](./examples) folder for more ways to use and setup the buildsystem.  

### Configuration
All the configuration variables are stored @[confy/cfg.nim](./src/confy/cfg.nim).  
To change them, just add `cfg.theVariable = value` at the top of your `build.nim` file.  
```nim
import confy
cfg.srcDir  = "./code"   # Changes the source code folder from its default `rootDir/"src"`.  
cfg.binDir  = "./build"  # Changes the binaries output folder from its default `rootDir/"bin"`.  
cfg.verbose = on         # Makes the cli output information completely verbose. (for debugging)
cfg.quiet   = on         # Makes the cli output information to be as minimal as possible.  (for cleaner cli output)  (default: on)  
                         # Note: verbose = on will ignore quiet being active.  (default: off)  
```
See the @[config.md](./doc/config.md) doc file, or @[confy/cfg.nim](./src/confy/cfg.nim) for the complete list of variables that can be modified.

