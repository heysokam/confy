# confy: Comfortable and Configurable buildsystem for C Compilers
Confy is a Buildsystem for compiling C code with Zig, GCC, Clang  _(todo: MinGW and Nim)_  
Inspired by SCons, without the issues of a typeless language.  
You can expect: 
- Ergonomic, readable and minimal/simple syntax.  
- Behaves as a library. Builds your own binary that runs the compilation commands.  
- Sane project configuration defaults, unless explicitely changed.   
- Builds with `zig cc` by default. Auto-downloads the latest version for the current host.  

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
See the [examples](./examples) folder for more ways to use the buildsystem.


```md
# warning
Depends on Nim2.0, which is on RC2 as of today.
Install nim with choosenim, and run:
> choosenim update devel

This step won't be needed when 2.0 becomes stable.
```
## Configuration
All the configuration variables are stored in [confy/cfg.nim](./src/confy/cfg.nim).  
To change them, just add `cfg.theVariable = value` at the top of your `build.nim` file.  
```nim
import confy
cfg.srcDir  = "./code"   # Changes the source code folder from its default `rootDir/"src"`.  
cfg.binDir  = "./build"  # Changes the binaries output folder from its default `rootDir/"bin"`.  
cfg.verbose = on         # Makes the cli output information completely verbose. (for debugging)
cfg.quiet   = on         # Makes the cli output information to be as minimal as possible.  (for cleaner cli output)  
                         # Note: verbose = on will ignore quiet being active.
```

---
**Done**:
- [x] Remote folders _(same concept as Repositories in SCons)_
- [x] make-to-confy converter
- [x] SharedLibrary build
- [x] Per-file formatted progress bar for binaries on quiet
- [x] BuildInfo report when not quiet (if not quiet)
- [x] Zig compiler:
  - [x] Automatic download into the configured `cfg.binDir` folder.
  - [x] Automatic updates from the latest stable version.
  - [x] C and C++ support
- [x] partial compiles: file cache database (sqlite3)
- [x] multi-object build
- [x] strip final binary on release vers
      (user sends the flags: `-Wl,-s`, `-strip-debug`, `-s`, etc, since its compiler-dependent)
- [x] ld.flags input support
- [x] cc.flags input support
- [x] support for grabbing all files contained in a folder (aka glob)
- [x] autocreate subdirs to compile into
- [x] multi-file build

**TODO**:
- [ ] Simultaneous multi-file compiling (-jN)  (using execProcesses)
- [ ] `-d` dependencies files management for headers.
      Rebuild the file if one of the header files in its .d file has been modified, but the file itself hasn't
- [ ] fix: need to force rebuild
- [ ] fix: make-to-confy missing ld flags
- [ ] select object to build by key
- [ ] confy clean
- [ ] StaticLibrary build
- [ ] Cross compilation support _(most likely will only support with Zig)_
- [ ] URL file `requires`
- [ ] Libs management as git.Submodules
- [ ] command line command parsing (for pkg-config, etc)   (note: windows with pkg-config-lite maybe?)

- [ ] More examples:
  - [ ] Advanced usage
  - [ ] Fully verbose example, changing everything that can be changed.

