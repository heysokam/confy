# confy: Comfortable Configuration tool for C Compilers
Confy is a Buildsystem for compiling C code with Zig, GCC, Clang  _(todo: MinGW and Nim)_  
Inspired by SCons, but without the problems of a typeless language.  
You can expect: 
- Ergonomic, readable and have a minimal/simple syntax.  
- Behaves as a library. Builds your own binary that runs the compilation commands.  
- Sane project configuration defaults, unless explicitely changed.   
- Builds with `zig cc` by default. Auto-downloads the latest version for the current host.  

---
**TODO**:
- [ ] `-d` dependencies files management. Rebuild the file if one of the files in its .d file has been modified, but the file itself hasn't
- [ ] Simultaneous multi-file compiling (-jN)  (using execProcesses)
- [ ] strip final binary on release vers
- [ ] select object to build by key
- [ ] confy clean
- [ ] Static build
- [ ] Libs management as git.Submodules
- [ ] URL file `requires`
- [ ] Repositories for C
- [ ] Repositories for Nim
- [ ] pkg-config parsing  (windows with pkg-config-lite)

**Done**:
- [x] multi-file build
- [x] create subdirs to compile into
- [x] multi-object build
- [x] partial compiles: file cache database (sqlite3)

