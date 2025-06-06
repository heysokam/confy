## get.Lang
- [x] Bun
- [x] Zig
- [ ] Nim
  - [x] Bootstrap
  - [ ] Nimble
- [ ] Minim
## All
- [x] Autocreate subdirs to compile into
- [x] Multi-file build
- [x] Support for file globbing _(automatic grabbing all files contained in a folder)_
- [x] cc.flags input support
- [x] ld.flags input support
- [ ] multi-object build
- [_] Per-file formatted progress bar for binaries on quiet
- [x] BuildInfo report when not quiet
- [x] cfg: configuration option:  `cfg.zigSystemBin`  (default:on)
           ZigCC uses the system's `zig` command when `cfg.zigSystemBin = on`.
           A local-only version is downloaded and used for the project when off.
- [x] Stop process when a previous step failed
- [ ] all: Keyword support. Select object to build by keyword sent from CLI
  - [ ] Keyword.all
  - [ ] Nim: Keyword.examples
  - [ ] Nim: Keyword.tests
- [ ] Watch Mode
      Call a `.watch()` method on `BuildTarget` that triggers a recompile on file changes
      Configurable: Refresh time, rerun binary, custom callback
- [ ] Options/arguments auto parser  (to avoid the user needing to implement parsing the info themselves)
  - [ ] Short option arguments
  - [ ] Long option arguments (variables) support   `key=val`
  - [ ] Arguments (non-files always interpreted as keywords)
- [_] Figure out: Support for JS & NPM Package
- [ ] Command line command parsing (for pkg-config, etc)   (note: windows with pkg-config-lite maybe?)
- [ ] Linking with `mold` on linux : https://github.com/rui314/mold/releases
### Dependencies
- [x] Libs management as git.Submodules ()
- [x] Automatic cloning to `libDir/name`
- [ ] Optional Opt-out: `--recurse-submodules`
## Zig
- [x] Compiler: Automatic download into the configured `cfg.binDir` folder.
- [ ] Compiler: Automatic updates from the latest stable version.
- [ ] SharedLibrary build
- [ ] StaticLibrary build
- [x] Modules
- [ ] `.def` files conversion support  _(eg: arocc requirements)_
- [ ] Defines feature
  > Builtin:
    defines.build.date
    defines.build.hash
    defines.build.version
    defines.build.mode
    defines.os  : builtin.os
- [ ] Give context/info about the target when building/running.
- [x] Support for sending extra arguments to the compiler.
- [x] strip final binary on release vers
- [ ] lto
## C and C++
- [x] Basic C support
- [x] Basic C++ support
- [x] Correctly select `C` or `C++` compiler inside a seq (found for each file, instead of globally for the whole list)
- [x] Remote folders _(same concept as Repositories in SCons)_
- [ ] SharedLibrary build
- [ ] windres with zig cc  (milestone feature for zig 0.11/0.12, request accepted on 2022.apr.09. https://github.com/ziglang/zig/issues/9564)
- [ ] [c,cpp] Fallback set of cc/ld flags, for both debug/release modes.
      Can specify flags, add the defaults explicitly, or just don't specify and use the fallback when omitted.
- [x] Support for sending extra arguments to the compiler.
- [ ] strip final binary on release vers
      (send the flags: `-Wl,-s`, `-strip-debug`, `-s`, to zigcc)
- [ ] lto
## Nim
- [x] Basic Nim code support _(with ZigCC)_
- [x] Cross compilation for Nim, with the same Zig-confy toolchain
- [ ] Fully verbose example, changing everything that can be changed.
- [x] Support for sending extra arguments to the compiler.
- [x] Support for the `cpp` nimc backend
- [x] strip final binary on release vers
- [x] lto
- [ ] Nimble-like `require "package"` in builder
- [ ] SharedLibrary build
- [ ] StaticLibrary build
- [ ] zigcc and zigcpp aliases:
  - [x] : Call for the system's `zig` command when `cfg.zig.systemBin = on`
  - [_] : Ordered to rebuild every run (in case the project is moved or the config options change).
          _Tiny file. Consumes less than a second in total._
          Done: Not needed with the new path resolution solution.

## Docs
- [_] Typedoc to Markdown
- [ ] Rewrite the configuration guide on `heysokam.github.io`
- [ ] Examples:
  - [x] Minimal
  - [ ] Basic usage
  - [ ] Advanced usage
  - [ ] Complex C cases  (passing confy.Object with different compile flags)

## Make to Confy
- [ ] Rewrite/Port to the Bun codebase
- [ ] Generation of confy globs, diffs and reference code lists for each target
- [ ] Converter

