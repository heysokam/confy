#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
##! @fileoverview Tools for Dependency Management
#_________________________________________________|
# @deps std
from std/os import `/`
from std/strformat import `&`
from std/strutils import join
# @deps confy
import ./types/base
import ./types/errors
import ./types/build
import ./log

export build.Dependency
export build.Dependencies

# # Bash
# proc sh *(cmd :string; dbg :bool= false) :void=
#   if dbg: echo cmd
#   if cfg.fakeRun: return
#   if os.execShellCmd(cmd) != 0: raise newException(OSError, &"Failed to run shell command:  {cmd}")

func git *(
    trg  : build.BuildTarget;
    args : ArgsList;
  ) :void=
  ## @descr Runs git with the given {@arg args} using a shell.
  let cmd  = trg.cfg.git.bin&" "&args.join(" ")
  let code = os.execShellCmd( cmd )
  if code != 0: trg.fail GitError, &"Git returned `{code}` for command:\n  {cmd}"


#_______________________________________
# @section Dependency Auto-Download Management
#_____________________________
func download *(
    trg : build.BuildTarget;
    dep : build.Dependency;
  ) :void=
  for subdep in dep.deps: trg.download(subdep)
  var cmd :ArgsList= @[]
  if dep.submodule.active:
    var dir = dep.submodule.dir
    if dir == "" : dir = trg.cfg.dirs.src/"lib"/dep.name
    {.cast(noSideEffect).}:
      if os.dirExists(dir): return
    # Run   git submodule add
    cmd.add "submodule"
    cmd.add "add"
    cmd.add dep.url
    cmd.add dir
    trg.git cmd
    # Clear and run   git submodule update
    cmd = @[]
    cmd.add "submodule"
    cmd.add "update"
    cmd.add "--init"
    cmd.add "--recursive"
    cmd.add dir
  else:
    let dir = trg.cfg.dirs.lib/dep.name
    {.cast(noSideEffect).}:
      if os.dirExists(dir): return
    # Run   git clone
    cmd.add "clone"
    cmd.add "--recurse-submodules"
    cmd.add dep.url
    cmd.add dir
  trg.git cmd
#___________________
func download *(trg :build.BuildTarget; _:typedesc[Dependencies]) :void=
  for dep in trg.deps: trg.download(dep)


#_______________________________________
# @section Nim: Dependencies to Arguments
#_____________________________
func nim_path (
    dep  : build.Dependency;
    dir  : PathLike = ".";
  ) :build.Arg=
  result.add "--path:"
  result.add( dir/dep.name/dep.src )
#___________________
func toNim *(
    dep  : build.Dependency;
    dir  : PathLike = ".";
  ) :build.ArgsList= @[dep.nim_path(dir)]
#___________________
func toNim *(
    deps : build.Dependencies;
    dir  : PathLike = ".";
  ) :build.ArgsList=
  for dep in deps: result.add dep.toNim(dir)


#_______________________________________
# @section Zig: Dependencies to Arguments
#_____________________________
func depOrModule (
    dep  : build.Dependency;
    dir  : PathLike = ".";    ## Root Local Folder where the library should be found
    root : bool     = false;  ## Whether this is a root module or not
  ) :build.ArgsList=
  # Add as --dep name and return when not a root/entry module
  if not root: return @["--dep", dep.name]
  # Add as -Mname=path/to/file.zig when root
  let file =
    if dep.entry != "": dep.entry
    else              : dep.name&".zig"
  let path = dir/dep.name/dep.src/file
  result = @[&"-M{dep.name}={path}"]
#___________________
func toZig *(
    dep  : build.Dependency;
    dir  : PathLike = ".";    ## Root Local Folder where the library should be found
    root : bool = false;      ## Whether this is a root module or not
  ) :build.ArgsList=
  # Add the sub-dependencies as --dep
  for subdep in dep.deps: result &= subdep.depOrModule(dir, root=false)
  # Add the root at the end
  result.add dep.depOrModule(dir, root)
#___________________
func toZig *(deps :build.Dependencies) :build.ArgsList=
  if deps.len == 0: return @[]

