# confy: Buildsystem for GCC, MinGW and Nim
Comfortable compiler configuraton tool.  
Inspired by SCons, but without the issues of a typeless language.  
Aims to be ergonomic, readable and have a minimal/simple syntax.  
Behaves as a library. It builds your own binary that runs the compilation commands.  
Comes with sane defaults.  

---
**TODO**:
- [ ] `-d` dependencies files management. Rebuild the file if one of the files in its .d file has been modified, but the file itself hasn't
- [ ] strip final binary on release vers
- [ ] select object to build by key
- [ ] confy clean
- [ ] Static build
- [ ] Libs management as git.Submodules
- [ ] URL file `requires`
- [ ] Repositories for C
- [ ] Repositories for Nim
- [ ] pkg-config parsing  (windows with pkg-config-lite)
- [ ] Simultaneous multi-file compiling (-jN)  (using execProcesses)

**Done**:
- [x] multi-file build
- [x] create subdirs to compile into
- [x] multi-object build
- [x] partial compiles: file cache database (sqlite3)

