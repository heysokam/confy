```md
# TODO:
- [ ] Nim: docgen task -> remove hardcoded repository. Add cfg.gitURL variable
- [ ] Nim: test   task:
  - [ ] Should create and run with confy.BuildTrg instead of just nimc
  - [ ] Test template support inside build.nim. Allows to quickly declare a test with ergonomic syntax.
- [ ] windres with zig cc  (milestone feature for zig 0.11/0.12, request accepted on 2022.apr.09. https://github.com/ziglang/zig/issues/9564)
**Less important, but todo**:
- [ ] More examples:
  - [ ] Advanced usage
- [ ] [c,cpp] Port the make-to-confy translator refactor into confy _(was never included)_
- [ ] [c,cpp] Fallback set of cc/ld flags, for both debug/release modes. (currently only supports one set without optimizations)
      You can specify your flags, add the defaults explicitly, or just don't specify and use the fallback when omitted.  
- [ ] command line command parsing (for pkg-config, etc)   (note: windows with pkg-config-lite maybe?)
- [ ] fix: make-to-confy missing ld flags
```
---
```md
# Done:
- [x] nim: Support for the `cpp` nimc backend
- [x] fix: Force-rebuild option for zigcc/zigcpp. Do not rebuild every time (becomes really repetitive to wait for them, even if short)
- [x] chg: Silence all hint config options for zigcc/zigcpp/build, unless verbose
- [x] fix: need to force rebuild
- [x] new: StaticLibrary build
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
---
```md
**Maybes**:
- [ ] Libs management as git.Submodules
```

