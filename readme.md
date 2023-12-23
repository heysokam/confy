> **Warning**:  
> This library is in the process of deprecating support for multiple builder backends  
> _(ie: gcc, clang, mingw, etc)_  
> ZigCC will be the only builder remaining after the [PR#5](https://github.com/heysokam/confy/pull/5) refactor.  
> _Nim, C and C++ compilation will continue to be supported._  

![Confy](./res/banner.png)
# confy: Comfortable and Configurable buildsystem for C and Nim
Confy is a Buildsystem for compiling code with ZigCC, GCC, Clang  _(todo: MinGW)_  
Inspired by SCons, without the issues of a typeless language.  
You can expect: 
- Ergonomic, readable and minimal/simple syntax.  
- Behaves as a library. Builds your own binary that runs the compilation commands.  
- Imperative, not declarative. You own the flow control of your builder.  
- Sane project configuration defaults, unless explicitely changed.   
- Builds with `zig cc` when compiler choice is omitted. Auto-downloads the latest version for the host.  

_Note: ZigCC is the main compiler used, but this doesn't mean we build Zig code._  
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

---
```md
# Done:
- [x] all: Keyword support. Select object to build by keyword sent from CLI
  - [x] Keyword.all
  - [x] Nim: Keyword.examples
  - [x] Nim: Keyword.tests
- [x] all: Tasks support
  - [x] Arbitrary User-defined tasks. Allows user-declared (project-specific) tasks like `clean`, etc  
  - [x] Nim: Task.docgen
  - [x] Nim: Task.push
- [x] Options/arguments auto parser  (to avoid the user needing to implement parsing the info themselves)
  - [x] Short option arguments
  - [x] Long option arguments (variables) support   `key=val`
  - [x] Arguments (non-files always interpreted as keywords)
- [x] Nim: Nimble-like `require "package"`
  - [x] in confy/nims caller script
  - [x] in build.nim
- [x] Nim: Examples template support inside build.nim. Allows to quickly declare an example with ergonomic syntax.
- [x] Nim: Fully verbose example, changing everything that can be changed.
- [x] Nim: Support for sending extra arguments to the compiler.
- [x] cfg: New configuration option:  `cfg.zigSystemBin`  (default:on)
         : ZigCC uses the system's `zig` command when `cfg.zigSystemBin = on`.
         : When off, a local-only version is downloaded and used for the project like before.
- [x] Nim: zigcc and zigcpp aliases:
  - [x]  : Now call for the system's `zig` command when `cfg.zigSystemBin = on`
  - [x]  : Are ordered to rebuild every run (in case the project is moved or the config options change).
         : Its a tiny file, so this process consumes less than a second in total.
- [x] Cross compilation for Nim, with the same Zig-confy toolchain
- [x] Nim code support (with ZigCC)
- [x] cfg: custom build filename when calling for the confy task 
         : (was default "build.nim", configurable from the `cfg.file` variable, but can be any name when calling the confy task)
- [x] Remote folders _(same concept as Repositories in SCons)_
- [x] make-to-confy: Generation of confy globs, diffs and reference code lists for each target
- [x] make-to-confy: Converter
- [x] SharedLibrary build
- [x] Per-file formatted progress bar for binaries on quiet
- [x] Correctly select `C` or `C++` compiler inside a seq (found for each file, instead of globally for the whole list)
- [x] BuildInfo report when not quiet (if not quiet)
- [x] Zig compiler:
  - [x] Automatic download into the configured `cfg.binDir` folder.
  - [x] Automatic updates from the latest stable version.
  - [x] C and C++ support
  - [x] Nim support
- [x] partial compiles: file cache database (sqlite3)
- [x] multi-object build
- [x] strip final binary on release vers
      (user sends the flags: `-Wl,-s`, `-strip-debug`, `-s`, etc, since its compiler-dependent)
- [x] ld.flags input support
- [x] cc.flags input support
- [x] support for grabbing all files contained in a folder (aka glob)
- [x] autocreate subdirs to compile into
- [x] multi-file build
```

```md
# TODO:
- [ ] nim: Support for the `cpp` nimc backend
- [ ] Force-rebuild option for zigcc/zigcpp. Do not rebuild every time (becomes really repetitive to wait for them, even if short)
- [ ] Silence all hint config options for zigcc/zigcpp/build, unless verbose
- [ ] Simultaneous multi-file compiling (-jN)  (using execProcesses)
- [ ] fix: need to force rebuild
- [ ] StaticLibrary build
- [ ] Nim: docgen task -> remove hardcoded repository. Add cfg.gitURL variable
- [ ] Nim: test   task:
  - [ ] Should create and run with confy.BuildTrg instead of just nimc
  - [ ] Test template support inside build.nim. Allows to quickly declare a test with ergonomic syntax.
- [ ] windres 
  - [ ] with zig cc  (milestone feature for zig 0.11/0.12, request accepted on 2022.apr.09. https://github.com/ziglang/zig/issues/9564)
  - [ ] with mingw   (note: only if/when mingw support is implemented)
- [ ] `-d` dependencies files management for headers.
**Less important, but todo**:
- [ ] More examples:
  - [ ] Advanced usage
- [ ] Fallback set of cc/ld flags, for both debug/release modes. (currently only supports one set without optimizations)
      You can specify your flags, and add the defaults explicitly, or just don't specify and use the fallback when omitted.  
- [ ] command line command parsing (for pkg-config, etc)   (note: windows with pkg-config-lite maybe?)
- [ ] fix: make-to-confy missing ld flags
```

```md
**Maybes**:
- [ ] Libs management as git.Submodules
- [ ] Cross compilation support for C with non-ZigCC compiler
```
