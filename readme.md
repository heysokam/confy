![Confy](./res/banner.png)
# confy: Comfortable and Configurable buildsystem
Confy is a buildsystem for compiling code with ZigCC.  
Inspired by SCons, without the issues of a typeless language.  
You can expect: 
- Ergonomic, readable and minimal/simple syntax.  
- Behaves like a library. Build your own binary that compiles your app.  
- Imperative, not declarative. You own the control flow.  
- Sane project and configuration defaults.  
- Auto-downloads the latest compiler for the host.  
- Cross-compilation as a **first class citizen**, not an afterthought.  

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

> Warning for Nim:  
> The compiler is set in the strictest mode possible by default.  
> Your code might not compile because of these flags.  
> You can deactivate or modify this behavior by changing the `Config().nim.unsafe` options  
> See the Configuration section below for more details.  

### Configuration
```nim
import confy
cfg.dirs.src = "./code"   # Changes the source code folder from its default `dirs.root/"src"`.  
cfg.dirs.bin = "./build"  # Changes the binaries output folder from its default `dirs.root/"bin"`.  
cfg.verbose  = on         # Makes the cli output information completely verbose. (for debugging)
cfg.quiet    = on         # Makes the cli output information to be as minimal as possible.  (for cleaner cli output)  (default: on)  
                          # Note: verbose = on will ignore quiet being active.  (default: off)  
```
Every build `Target` has its own separate configuration options, decided when first creating that target.
When omitted, Confy uses a global configuration variable that you can modify.
To change its values, add `cfg.theVariable = value` anywhere in your `build.nim` file.  

You can also create your own `confy.Config()` object and pass it as the `cfg = ...` argument to each `confy.Target` you create.
Confy does this automatically, but it uses the global config state/variable for ergonomics when omitted.
In practice, this means that if you pass your own Config object to a target,  
confy will ignore the global variable and only use your config instead.  

You can find the complete list of default options at @[confy/types/config.nim](./src/confy/types/config.nim)

#### Comptime defaults
All the comptime configuration variables are stored @[confy/cfg.nim](./src/confy/cfg.nim).  
Without changing anything else, you can override these options by compiling your builder with a different value.  
For example, this will compile and run your builder, and change the default to use system/PATH binaries for everything
```nim
nim c -r -d:confy.all_systemBin=off build.nim
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

