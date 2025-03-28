![Confy](./res/banner.png)
# confy: Comfortable and Configurable buildsystem
Confy is a buildsystem for compiling code with ZigCC.  
Inspired by SCons, without the issues of a typeless language.  
You can expect: 
- Ergonomic, readable and minimal/simple syntax.  
- Behaves as a library. Builds your own binary that runs the compilation commands.  
- Imperative, not declarative. You own the flow control of your builder.  
- Sane project configuration defaults.  
- Builds with `zig cc`. Auto-downloads the latest version for the host.  

_Note: ZigCC is the binary compiler used, but this doesn't mean we build Zig code._  
_This project is used to build C, C++ and Nim projects._  

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


## Disclaimer / Notes
Please read the @[how to](./doc/howto.md) doc before reading this section:

### `build.nim` is NOT a buildscript
Confy is a buildsystem **library**.  
The default setup provides you with an easy way to run it as if it had a binary...
but confy is actually **not** a binary app, and this is by design.  

The `build.nim` file is **your** binary application, that you build with the nim compiler to build your project, from the Caller Script.  

Because of this, there is no weird make-specific shell-only language problematic restrictions in here.  
There is no interpreted-language-only-things restriction either, like python.  
There is no "only runs on the VM" problems either.  
The Builder App is a full-blown binary that can do literally anything you want.  

In make-related buildsystems, you **do not own** the control flow.  
If you want to do extra things that the `make` creators didn't think of, you are on your own.  
And have to call for external applications and make your buildsystem overly complicated for no reason.  

Confy, instead, provides you with a -library- of functions and types to build your project.  
It is created to make this process seamless and ergonomic, as if it was a regular buildscript.  
But the Builder app is compiled systems binary.  
It can do literally -anything- a normal compiled systems binary can do.  

