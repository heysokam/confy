## get.Lang
- [x] Bun
- [x] Zig
- [ ] Nim
  - [x] Bootstrap
  - [ ] Nimble
- [ ] Minim
## All
- [ ] Autocreate subdirs to compile into
- [ ] Multi-file build
- [ ] Support for file globbing _(automatic grabbing all files contained in a folder)_
- [ ] ld.flags input support
- [ ] cc.flags input support
- [ ] multi-object build
- [ ] strip final binary on release vers
      (user sends the flags: `-Wl,-s`, `-strip-debug`, `-s`, etc, since its compiler-dependent)
- [ ] Per-file formatted progress bar for binaries on quiet
- [ ] BuildInfo report when not quiet
- [ ] cfg: configuration option:  `cfg.zigSystemBin`  (default:on)
           ZigCC uses the system's `zig` command when `cfg.zigSystemBin = on`.
           A local-only version is downloaded and used for the project when off.
- [ ] Stop process when a previous step failed
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
- [ ] Figure out: Support for JS & NPM Package
      ```json
      "files": [ "public" ],
      "main": "public/index.js",
      "types": "public/index.d.ts",
      ```
- [ ] Command line command parsing (for pkg-config, etc)   (note: windows with pkg-config-lite maybe?)
- [ ] Linking with `mold` on linux : https://github.com/rui314/mold/releases
### Dependencies
- [ ] Libs management as git.Submodules ()
- [ ] Automatic cloning to `libDir/name`
- [ ] Optional Opt-out: `--recurse-submodules`
## Zig
- [x] Compiler: Automatic download into the configured `cfg.binDir` folder.
- [ ] Compiler: Automatic updates from the latest stable version.
- [ ] SharedLibrary build
- [ ] StaticLibrary build
- [ ] Modules
- [ ] `.def` files conversion support  _(eg: arocc requirements)_
- [ ] Defines feature
  > Builtin:
    defines.build.date
    defines.build.hash
    defines.build.version
    defines.build.mode
    defines.os  : builtin.os
- [ ] Give context/info about the target when building/running.
## C and C++
- [ ] Basic C support
- [ ] Basic C++ support
- [ ] Correctly select `C` or `C++` compiler inside a seq (found for each file, instead of globally for the whole list)
- [ ] Remote folders _(same concept as Repositories in SCons)_
- [ ] SharedLibrary build
- [ ] windres with zig cc  (milestone feature for zig 0.11/0.12, request accepted on 2022.apr.09. https://github.com/ziglang/zig/issues/9564)
- [ ] [c,cpp] Fallback set of cc/ld flags, for both debug/release modes.
      Can specify flags, add the defaults explicitly, or just don't specify and use the fallback when omitted.
## Nim
- [ ] Basic Nim code support _(with ZigCC)_
- [ ] Cross compilation for Nim, with the same Zig-confy toolchain
- [ ] Fully verbose example, changing everything that can be changed.
- [ ] Support for sending extra arguments to the compiler.
- [ ] Support for the `cpp` nimc backend
- [ ] Nimble-like `require "package"` in builder
- [ ] SharedLibrary build
- [ ] StaticLibrary build
- [ ] zigcc and zigcpp aliases:
  - [ ] : Call for the system's `zig` command when `cfg.zigSystemBin = on`
  - [_] : Ordered to rebuild every run (in case the project is moved or the config options change).
          _Tiny file. Consumes less than a second in total._
          Done: Not needed with the new path resolution solution.

## Docs
- [ ] Typedoc to Markdown
- [ ] Rewrite the configuration guide on `heysokam.github.io`
- [ ] Examples:
  - [ ] Basic usage
  - [ ] Advanced usage

## Make to Confy
- [ ] Rewrite/Port to the Bun codebase
- [ ] Generation of confy globs, diffs and reference code lists for each target
- [ ] Converter

