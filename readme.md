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
const hello = Program.new("hello.c")
hello.build()
hello.run()
```

## How to Use
> TODO:  
> Full **how-to** guide @[doc/howto](./doc/howto.md)  
> See the [examples](./examples) folder in the meantime


## Design Decisions
> _Summary of: [doc/design.md](./doc/design.md)_

Please read the @[how to](./doc/howto.md) doc before reading this section:

### Imperative, not Declarative
When most people think of a build tool, they think of declarativeness.  
This is **not** what Confy is.  

Confy is completely imperative.  
What you tell Confy to do, it will do **immediately**.  

The core the concept behind Confy is that you fully own your buildsystem.  
Its your project, and only you can know what your project/tooling needs,  
and in which exact order.  

### `build.nim` is NOT a buildscript
Confy is a buildsystem **library**.  
The premade caller provides you with an easy way to run it as if it was a binary,  
but confy is, by design, **not** a binary app.  

**Your build file** (not confy) will be a full systems binary application,  
that you compile with nim's compiler _(or automated with confy's premade caller)_ to build your project.  

Because of this:
- There is no weird make-specific or shell-only language restrictions, like make/cmake.  
- There is no interpreted-language restrictions either, like in python.  
- There is no "can only do what the VM can do" problems either, like nimscript or lua.  
- Your builder will be a full systems binary, that will be able to do literally anything you want.  

### Why ZigCC
ZigCC comes with all of these features **builtin**, out of the box. No extra setup:
- Automatic Caching
- Cross-platform Cross-compilation
  _(from any system to any system, not just some to some)_
- Auto-dependency resolution
- Preconfigured Sanitization
- Sane and Modern optimization defaults
- Pre-packed libc

... and all of that fits in a self-contained 50mb download!  

Compare that to setting up gcc/mingw/msys/msvc/clang/osxcross ... etc, etc, etc  
I say there is a clear winner here.  

