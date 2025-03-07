```md
# Outdated
- [x] fix: make-to-confy missing ld flags
- [x] fix: Force-rebuild option for zigcc/zigcpp. Do not rebuild every time (becomes really repetitive to wait for them, even if short)
- [x] fix: need to force rebuild
- [x] [c,cpp] Port the make-to-confy translator refactor into confy _(was never included)_
- [x] chg: Silence all hint config options for zigcc/zigcpp/build, unless verbose
```

```md
# Not wanted
- [_] Nim: Nimble-like `require "package"` in confy/nims caller script
- [_] Nim: docgen task -> remove hardcoded repository. Add cfg.gitURL variable
- [_] Nim: test   task:
  - [_] Should create and run with confy.BuildTrg instead of just nimc
  - [_] Test template support inside build.nim. Allows to quickly declare a test with ergonomic syntax.
```

```md
# @heysokam/spry
- [x] cfg: custom build filename when calling for the confy task 
           (was default "build.nim", configurable from the `cfg.file` variable, but can be any name when calling with spry)
- [ ] all: Tasks support
  - [ ] Arbitrary User-defined tasks. Allows user-declared (project-specific) tasks like `clean`, etc  
  - [ ] Nim: Task.docgen
  - [ ] Nim: Task.push
- [ ] Nim: Examples template support inside build.nim. Allows to quickly declare an example with ergonomic syntax.
- [_] partial compiles: file cache database (sqlite3)
```

