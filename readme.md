# confy: Buildsystem for GCC, MinGW and Nim
Inspired by SCons, without the baggage of Python.  
Aims to be comfortable and have a minimal/simple syntax.  
Behaves as a library. It will build your own binary that runs the compilation commands.  
Comes with sane defaults.  

---
**TODO**:
- [ ] create subdirs to compile into
- [ ] multi-object build
- [ ] `-d` dependencies files management. Rebuild the file if one of the files in its .d file has been modified, but the file itself hasn't
- [ ] partial compiles: file cache
- [ ] select object to build by key
- [ ] confy clean
- [ ] Static build
- [ ] Libs management as git.Submodules
- [ ] URL file `requires`
- [ ] Repositories for C
- [ ] Repositories for Nim

**Done**:
- [x] multi-file build

