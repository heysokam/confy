//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps libs
import * as git from 'simple-git'
import * as std_os from 'process'
// @deps confy
import * as log from '../log'
import { cfg as confy } from '../cfg'
import { Dir, File, Path } from '../tools'
import * as shell from '../tools/shell'
import { Manager } from '../manager'
// import { Manager } from '@confy/manager'
export namespace Nim {

//______________________________________
// @section Generic Nim config
//____________________________
export const name = "nim"


//______________________________________
// @section Bootstrapping Tools
//____________________________
export namespace Bootstrap {
  export namespace get {
    export function version (
        cfg : confy.Config = confy.defaults.clone(),
      ) :string { return (cfg.nim.version === confy.Version.Named.latest)
      ? "version-2-2"  // FIX: Remove hardcoded 2-2. Figure out the latest from naming convention
      : cfg.nim.version
    }

    export const patch = (cfg :confy.Config):string=> Nim.Bootstrap.get.Patch.zigcc(Nim.Bootstrap.Zig.cc.path(cfg))
    export namespace Patch {
      export const zigcc = (ZIGCC :string):string=> // @warning Needs newline at the end, and can't start with a newline
`diff --git a/config/nim.cfg b/config/nim.cfg
index 1470de780..c41b9d203 100644
--- a/config/nim.cfg
+++ b/config/nim.cfg
@@ -362,3 +362,7 @@ tcc.options.always = "-w"
   clang.options.linker %= "\${clang.options.linker} -s"
   clang.cpp.options.linker %= "\${clang.cpp.options.linker} -s"
 @end
+
+--cc:clang
+--clang.exe:"${ZIGCC}"
+--clang.linkerexe:"${ZIGCC}"
diff --git a/koch.nim b/koch.nim
index b927024b3..745c01e89 100644
--- a/koch.nim
+++ b/koch.nim
@@ -334,7 +334,7 @@ proc boot(args: string, skipIntegrityCheck: bool) =
     let defaultCommand = if useCpp: "cpp" else: "c"
     let bootOptions = if args.len == 0 or args.startsWith("-"): defaultCommand else: ""
     echo "iteration: ", i+1
-    var extraOption = ""
+    var extraOption = "--cc:clang --clang.exe=\\"${ZIGCC}\\" --clang.linkerexe=\\"${ZIGCC}\\""
     var nimi = i.thVersion
     if i == 0:
       nimi = nimStart
`; //:: Nim.Bootstrap.get.Patch.zigcc
    } //:: Nim.Bootstrap.get.Patch
  } //:: Nim.Bootstrap.get

  export namespace Zig {
    export const extension = ".zig"
    /**
     * @description
     * Zig file that calls `zig cc` with any arguments passed to the parent.
     * Reads its own name to decide if it should call `zig cc`, `zig cpp`, etc
     * It will always run the `./zig` binary that is right next to itself.
     * Uses an auto-resolved absolute path no matter where it is called from.
     * */
    export const code =():string=>`const std = @import("std");
pub fn main() !u8 {
  var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator); defer arena.deinit(); const A = arena.allocator();
  const dir = try std.fs.selfExeDirPathAlloc(A); defer A.free(dir);
  const zig = try std.fs.path.join(A, &.{ dir, "zig" }); defer A.free(zig);
  var   cmd = std.ArrayList([]const u8).init(A); defer cmd.deinit();
  try cmd.append(zig);
  var args   = try std.process.argsWithAllocator(A); defer args.deinit();
  const self = args.next() orelse ""; // Check arg0 for cc c++ etc
       if (std.mem.endsWith(u8, self, "cc" )) { try cmd.append("cc" ); }
  else if (std.mem.endsWith(u8, self, "cpp")) { try cmd.append("c++"); }
  else if (std.mem.endsWith(u8, self, "ar" )) { try cmd.append("ar" ); }
  else if (std.mem.endsWith(u8, self, "rc" )) { try cmd.append("rc" ); }
  else                                        { try cmd.append("cc" ); }
  while (args.next()) |arg| try cmd.append(arg); // Passthrough all args
  var   P = std.process.Child.init(cmd.items, A);
  const R = try std.process.Child.spawnAndWait(&P);
  return R.Exited;
}
`;

    export namespace cc {
      export const path = (cfg :confy.Config):string=> Path.toAbsolute(cfg.zig.bin.toString()+"cc").toString()
      export async function build (
          cfg   : confy.Config = confy.defaults.clone(),
          force : boolean      = false,
        ) :Promise<void> {
        const trg = Nim.Bootstrap.Zig.cc.path(cfg)
        if (File.exists(trg) && !force) return
        if (force) File.rmv(trg)
        const src = trg+Zig.extension
        log.verb(cfg, `Nim: Building ZigCC from: `, src, " into binary: ", trg)
        File.write(src, Nim.Bootstrap.Zig.code())
        // Define the compilation command for zigcc
        const cmd   = ["build-exe"]
        const cache = cfg.zig.cache.toString()
        cmd.push("--cache-dir", cache, "--global-cache-dir", cache)
        cmd.push(src, `-femit-bin=${trg}`, "-fno-llvm", "-fno-lld")
        // Compile zigcc
        await Manager.Zig.run(cfg, ...cmd)
      } //:: Nim.Bootstrap.Zig.cpp.build
    } //:: Nim.Bootstrap.Zig.cc


    export namespace cpp {
      export const path = (cfg :confy.Config):string=> Path.toAbsolute(cfg.zig.bin.toString()+"cpp").toString()
      export async function build (
          cfg   : confy.Config = confy.defaults.clone(),
          force : boolean      = false,
        ) :Promise<void> {
        const trg = Nim.Bootstrap.Zig.cpp.path(cfg)
        if (File.exists(trg) && !force) return
        if (force) File.rmv(trg)
        const src = Nim.Bootstrap.Zig.cc.path(cfg)
        log.verb(cfg, `Nim: Duplicating ZigCC from: `, src, " into: ", trg)
        if (File.exists(src)) await Nim.Bootstrap.Zig.cc.build(cfg, force)
        File.cp(src, trg)
      } //:: Nim.Bootstrap.Zig.cpp.build
    } //:: Nim.Bootstrap.Zig.cpp
  } //:: Nim.Bootstrap.Zig

  export async function clone (
      cfg   : confy.Config = confy.defaults.clone(),
      force : boolean      = false,
    ) :Promise<void> {
    log.verb(cfg, "Nim: Cleaning cloned repository (cache/nim) ...")
    if (force) Dir.rmv(cfg.dir.cache)
    if (!Dir.exists(cfg.dir.cache)) Dir.create(cfg.dir.cache)
    // FIX: Generic git clone
    const host = cfg.nim.git.host.toString()
    const url  = host+cfg.nim.git.owner.toString()+"/"+cfg.nim.git.repo.toString()
    const dir  = cfg.nim.cache.toString()
    const vers = Nim.Bootstrap.get.version(cfg)
    const brch = ((cfg.nim.git.branch) ? cfg.nim.git.branch.toString() : vers)
    const cmd  = git.simpleGit()
    const opts = ["-j8", "--depth=1", "--recurse-submodules", "-b", brch]
    log.verb(cfg, `Nim: Cloning version \`${vers}\` from: `, url, "\n  git", ...opts, url, dir)
    await cmd.clone(url, dir, opts)
    log.verb(cfg, "Nim: Done cloning from: ", url)
  } //:: Nim.Bootstrap.clone

  export async function reset (
      cfg : confy.Config = confy.defaults.clone(),
    ) :Promise<void> {
    const cmd  = git.simpleGit(cfg.nim.cache.toString())
    /* git clean  -fdx  */ await cmd.clean([git.CleanOptions.FORCE, git.CleanOptions.RECURSIVE, git.CleanOptions.IGNORED_INCLUDED])
    /* git reset --hard */ await cmd.reset(git.ResetMode.HARD)
  }

  export async function patch (
      cfg   : confy.Config = confy.defaults.clone(),
      force : boolean      = false,
    ) :Promise<void> {
    if (force) await Nim.Bootstrap.reset(cfg)
    const data = Nim.Bootstrap.get.patch(cfg)
    const name = "./zigcc.patch"
    const file = Path.join(cfg.nim.cache, name)
    File.write(file, data)
    const cmd  = git.simpleGit(cfg.nim.cache.toString())
    await cmd.applyPatch(name)
  } //:: Nim.Bootstrap.patch


  export async function zigcc (
      cfg   : confy.Config = confy.defaults.clone(),
      force : boolean      = false,
    ) :Promise<void> {
    await Nim.Bootstrap.Zig.cc.build(cfg, force)
    await Nim.Bootstrap.Zig.cpp.build(cfg, force)
  } //:: Nim.Bootstrap.zigcc

  export namespace Build {
    export const binDir  = "bin"
    export const script  =():string=> (std_os.platform === "win32") ? "./build_all.bat" : "./build_all.sh"
    export const command =(_:confy.Config):string[]=> [Nim.Bootstrap.Build.script()]  // eslint-disable-line @typescript-eslint/no-unused-vars
  } //:: Nim.Bootstrap.Build

  export async function build (
      cfg   : confy.Config = confy.defaults.clone(),
      force : boolean      = false,
    ) :Promise<void> {
    if (force) Dir.rmv(Path.join(cfg.nim.cache, Nim.Bootstrap.Build.binDir))
    const cmd = Nim.Bootstrap.Build.command(cfg)
    const cc  = Nim.Bootstrap.Zig.cc.path(cfg)

    const prev = process.cwd()  // cwd save
    process.chdir(cfg.nim.cache.toString())
    log.verb(cfg, `Nim: Building from:  ${process.cwd()}  with command: `, ...cmd)
    await shell.exec({env: {...process.env, CC: cc}}, ...cmd)
    log.verb(cfg, "Nim: Done building.")
    process.chdir(prev)  // cwd restore
  } //:: Nim.Bootstrap.build
} //:: Nim.Bootstrap


//______________________________________
// @section File Tools
//____________________________
/** @warning Will fail when cfg.zig.systemBin is on */
export const exists = (
  cfg: confy.Config = confy.defaults.clone()
) :boolean=> /* FIX: */ File.exists((cfg.nim.systemBin) ? cfg.nim.name : cfg.nim.bin)

export namespace Download {
  export async function nim ( // eslint-disable-line @typescript-eslint/require-await
      cfg   : confy.Config = confy.defaults.clone(),
      force : boolean      = false,
    ) :Promise<void> {force; // eslint-disable-line @typescript-eslint/no-unused-expressions
    // nimble --nimbleDir:/yourPath install nim
    log.fail(cfg, "Nim: Downloading Binaries without bootstrapping is not implemented yet.")
  }
}

//______________________________________
// @section get.Nim: Entry Points
//____________________________
export async function bootstrap (
    cfg   : confy.Config = confy.defaults.clone(),
    force : boolean      = false,
  ) :Promise<void> {
  log.verb(cfg, "Nim: Starting the Bootstrap process using ZigCC from: ", Nim.Bootstrap.Zig.cc.path(cfg))
  await Nim.Bootstrap.clone(cfg, force)
  await Nim.Bootstrap.patch(cfg, force)
  await Nim.Bootstrap.zigcc(cfg, force)
  await Nim.Bootstrap.build(cfg, force)
} //:: Nim.bootstrap

export async function release (
    cfg   : confy.Config = confy.defaults.clone(),
    force : boolean      = false,
  ) :Promise<void> {
  await Nim.Download.nim(cfg, force)
} //:: Nim.release

export async function download (
    cfg   : confy.Config = confy.defaults.clone(),
    force : boolean      = false,
  ) :Promise<void> {
  if (Nim.exists(cfg) && !force) return log.verb(cfg, "Nim: Already exists. Omitting download.")
  log.verb(cfg, "Nim: Starting download into: ", cfg.nim.dir)
  if (cfg.nim.bootstrap) await Nim.bootstrap(cfg, force)
  else                   await Nim.release(cfg, force)
  log.verb(cfg, "Nim: Copying data from: ", cfg.nim.cache, " into: ", cfg.nim.dir)
  Dir.move(cfg.nim.cache, cfg.nim.dir)
  log.verb(cfg, "Nim: Done downloading.")
} //:: Nim.download


} //:: Nim


// Alternative export
export const getNim = {
  exists    : Nim.exists,
  download  : Nim.download,
  bootstrap : Nim.bootstrap,
  release   : Nim.release,
}

