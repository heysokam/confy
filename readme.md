![Confy](./res/banner.png)
# confy: Comfortable and Configurable buildsystem
Confy is a buildsystem for compiling code with ZigCC.  
Inspired by SCons, without the issues of a typeless language.  
You can expect: 
- Ergonomic, readable and minimal/simple syntax.  
- Behaves like a library. Build your own binary that runs the compilation commands.  
- Imperative, not declarative. You own the control flow.  
- Sane project configuration defaults.  
- Builds with `zig cc`. Auto-downloads the latest version for the host.  

## Preview
Minimal build file:
```nim
import confy
Program.new("hello.c").build.run
```

## How to Use
> TODO:  
> Full **how-to** guide @[doc/howto](./doc/howto.md)  
> See the [examples](./examples) folder in the meantime

### Configuration
All the configuration variables are stored @[confy/cfg.nim](./src/confy/cfg.nim).  
To change them, add `cfg.theVariable = value` at the top of your `build.nim` file.  
```nim
import confy
cfg.dirs.src = "./code"   # Changes the source code folder from its default `dirs.root/"src"`.  
cfg.dirs.bin = "./build"  # Changes the binaries output folder from its default `dirs.root/"bin"`.  
cfg.verbose  = on         # Makes the cli output information completely verbose. (for debugging)
cfg.quiet    = on         # Makes the cli output information to be as minimal as possible.  (for cleaner cli output)  (default: on)  
                          # Note: verbose = on will ignore quiet being active.  (default: off)  
```


## Design Decisions
> _Summary of: [doc/design.md](./doc/design.md)_

Please read the @[how to](./doc/howto.md) doc before reading this section:

### Imperative, not Declarative
When most people think of a build tool, they think of declarativeness.  
This is **not** what Confy is.  

Confy is completely imperative.  
This is by design.  
What you tell Confy to do, it will do **immediately**.  

The core idea driving Confy is to let you fully own your buildsystem.  
Its your project, and only you can know what your project/tooling needs,  
and in which exact order.  

### `build.nim` is not a buildscript
Confy is a buildsystem **library**.  
The premade caller provides you with an easy way to run it as if it was a binary,  
but confy is, by design, **not** a binary app.  

**Your build file** _(not confy, big difference)_ will be a full systems binary application,  
that you compile with nim's compiler _(or automated with confy's premade caller)_ to build your project.  

### Why ZigCC
ZigCC comes with all of these features **builtin**, out of the box. No extra setup:
- Automatic Caching
- Cross-platform Cross-compilation
  _(from any system to any system, not just some to some)_
- Auto-dependency resolution
- Preconfigured Sanitization
- Sane and Modern optimization defaults
- Pre-packed libc

... and all of that fits in a self-contained 50mb download.... !!  

Compare that to setting up gcc/mingw/msys/msvc/clang/osxcross ... etc, etc, etc  
There is a clear winner here.  

