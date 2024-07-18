//!:______________________________________________________________________
//! ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//!:______________________________________________________________________
//!
//! @fileoverview
//!  Automated Git Manager
//!
//________________________________________________________________________|
const gman = @This();
// @deps std
const std  = @import("std");
const http = std.http;
// @deps zstd
const zstd = @import("./lib/zstd.zig");
const cstr = zstd.cstr;
const cstr_List = zstd.cstr_List;
const echo = zstd.echo;
const prnt = zstd.prnt;
const git  = zstd.git;

const Prefix = "Ͼ gman: ";

const commits = struct {
  // TODO:   const SkipTags * = ["git:", "doc:", "tst:", "bld:", "fmt:"]
  const FilterTags = &.{"git:", "doc:", "tst:", "bld:", "fmt:"};
  fn shouldFilter (C :*const git.Commit, tags :cstr_List) bool {
    for (tags) | tag | {
      if (std.mem.startsWith(u8, C.msg, tag)) return true;
    }
    return false;
  }
  fn filter (list :*git.Commit.List, last :cstr, skip :cstr_List) void {
    var to :usize= 0;
    var found :bool= false;
    for (0..list.items.len) | from | {
      list.items[to] = list.items[from]; // Move the items backwards when needed
      // Skip the tags that we don't want to track
      if (gman.commits.shouldFilter(&list.items[to], skip)) continue;
      // Save items that match the condition: Increment target index by one, so that we don't override this item on the next iteration step
      if (found) to += 1;  // Keep commits that match the condition
      if (std.mem.eql(u8, list.items[to].hash, last)) found = true;
    }
    list.shrinkRetainingCapacity(to);
  }

  fn pending (lastcommit :cstr, skip :cstr_List, A :std.mem.Allocator) !git.Commit.List {
    // Get the list of commits from last to current
    var result = try git.log.commits.all(A);
    // Get the last commit that was sent, and filter the resulting list
    const last = try gman.secret.read(lastcommit, A);
    defer A.free(last);
    gman.commits.filter(&result, last, skip);
    return result;
  }

  fn save (list :*const git.Commit.List, lastcommit :cstr) !void {
    if (list.items.len == 0) return;  // An empty list has nothing to save to the file
    // TODO: Append to the top of the file, instead of overwriting the file
    try std.fs.cwd().writeFile(std.fs.Dir.WriteFileOptions{
      .sub_path   = lastcommit,
      .data       = list.items[list.items.len-1].hash,
      .flags      = std.fs.File.CreateFlags{
        .read     = true,   // Create with read access
        .truncate = true,   // Erase the existing contents of the file
        .mode     = 0o644,  // Set to -rw-r--r-- on linux (ignored otherwise)
        }, // << CreateFlags{ ... }
      }); // << WriteFileOptions{ ... }
    // @ref to implement file append/prepend:
    // Ensure path exists : std.fs.cwd().createFile(path, .{.read = true, .truncate = false})
    // Expect path exists : std.fs.cwd().openFile(path, .{.mode = .read_write})
  }
};

const discord = struct {
  const commit = struct {
    /// @note Caller must free the resulting string
    fn message (C :*const git.Commit, repo :cstr, url :cstr) ![]u8 {
      return try std.fmt.allocPrint(C.A, "[{s}]({s}): {s}", .{repo, url, C.msg});
    }
    /// @descr Gets the message of the {@arg C} commit and sends it to the {@arg H} hook, formatted using the {@arg R} repository information
    fn send (C :*const git.Commit, R :*const git.Repo, H :cstr) !void {
      const url = try R.url(C.A);
      defer C.A.free(url);
      const M = try discord.commit.message(C, R.name, url);
      defer C.A.free(M);
      try discord.msg.send(M, H, C.A);
    }
  };
  const commits = struct {
    fn send (list :*const git.Commit.List, R :*const git.Repo, H :cstr) !void {
      // let overLimit = commits.len >= 30
      // let secs      = commits.len*2
      // let time      = if secs > 60: &"{secs div 60}mins" else: &"{secs}secs"
      // if overLimit: cli.warn &"Sending {commits.len} messages to discord, which is over the 30msg/60sec limit.\n  Will wait for 2sec between each send.\n  It will take {time} to finish."
      // for commit in commits:
      //   commit.send(H)
      //   if overLimit: nstd.wait(sec=2) # Never hit the 30msg/60sec limit for webhooks : https://twitter.com/lolpython/status/967621046277820416

      const stagger = discord.msg.stagger.should(list);
      if (stagger) { try discord.msg.stagger.report(list); }

      for (list.items) | C | {
        prnt(gman.Prefix++"Send ::   {s}\n", .{C.msg});
        try discord.commit.send(&C, R, H);
        if (stagger) discord.msg.stagger.wait();
      }
    }
  };

  const MsgData = struct {
    content :cstr,
  };
  const CommitMsg = struct {
    const Templ = "[{s}]({s}): {s}";  // const MsgTempl = "[$1]($2): $3"
    // [       $1       ](      $2       ): $3
    // [commit.repo.name](commit.repo.url): commit.title
    // [minc](https://github.com/heysokam/minc]: new: Support for some fancy feature
    title  :cstr,
    repo   :Repo,

    const Repo = struct {
      name  :cstr,
      url   :cstr,
    };

    pub fn format(M :*const discord.CommitMsg, comptime _:[]const u8, _:std.fmt.FormatOptions, writer :anytype) !void {
      try writer.print(discord.Msg.Templ, .{M.repo.name, M.repo.url});
    }
  };

  const msg = struct {
    /// @descr Ergonomic Tools to work with discord message bandwidth limits (aka staggering)
    const stagger = struct {
      /// @descr Maximum number of messages that Discord allows sending to a hook per second
      const MaxPerSec = 2;
      /// @descr Maximum number of messages that Discord allows sending to a hook per second
      const MaxPerMin = 60/MaxPerSec;
      /// @descr Waits for the necessary amount of time required for the discord hook to not ignore our messages when over the limit
      /// @ref Limit for webhooks : 30msg/60sec  ->  https://twitter.com/lolpython/status/967621046277820416
      fn wait () void { std.time.sleep(std.time.ns_per_s * discord.msg.stagger.MaxPerSec); }
      /// @descr Returns whether or not we should stagger sending the {@arg list} of commits to discord, to not lose any messages due to bandwidth limits
      fn should (list :*const git.Commit.List) bool { return list.items.len >= MaxPerMin; }
      // @descr Message that will be reported to CLI when staggering the list of messages sent
      const Templ = gman.Prefix ++
        \\ Sending {d} messages to discord, which is over the {d}msg/60sec limit. Will wait for {d}sec between each send.
        \\  It will take {s} to finish.
        ;
      /// @descr Reports to CLI the total amount of time that it will take to send all messages for the {@arg list} of commits
      fn report (list :*const git.Commit.List) !void {
        const count = list.items.len;
        const secs  = count*discord.msg.stagger.MaxPerSec;
        // Create the time part of the message
        const time =
          if (secs > 60) try std.fmt.allocPrint(list.allocator, "{d}min", .{ secs/60 })
          else           try std.fmt.allocPrint(list.allocator, "{d}sec", .{ secs    });
        defer list.allocator.free(time);
        // Create the final message
        const m = try std.fmt.allocPrint(list.allocator, discord.msg.stagger.Templ, .{
          count, MaxPerMin, MaxPerSec,
          time,
          });
        defer list.allocator.free(m);
        // Send it to CLI
        echo(m);
      }

    };

    fn send (M :cstr, H :cstr, A :std.mem.Allocator) !void {
      var client = http.Client{.allocator= A};
      defer client.deinit();

      const message = MsgData{.content= M};

      const data = try std.json.stringifyAlloc(A, message, .{});
      const url  = try gman.secret.read(H, A);  // Read the hook URL from the {@arg H} hook's file path
      defer A.free(url);

      // Create the request
      var buf :[50*1024]u8=  undefined;
      var req = try client.open(.POST, try std.Uri.parse(url), http.Client.RequestOptions{
        .server_header_buffer = &buf,             // Externally-owned memory used to store the server's entire HTTP header.
        .headers              = .{                // (default:  .{}) Standard headers that have default, but overridable, behavior.
          .content_type       = http.Client.Request.Headers.Value{.override= "application/json"},
          }, // << headers
        // Defaults
        .version              = .@"HTTP/1.1",
        .handle_continue      = true,             // (default: true) Automatically ignore 100 Continue responses.
        .keep_alive           = true,             // (default: true) Participate in the client connection pool when true. Close the connection after one request when false.
        .redirect_behavior    = @enumFromInt(3),  // (default:    3) Specifies whether to automatically follow redirects or not, and how many redirects to follow before returning an error.
        .connection           = null,             // (default: null) Must be an already acquired connection.
                                                  //
        // content_type: Value = .default,
        .extra_headers        = &.{},             // (default: &.{}) Kept when following a redirect to a different domain.
        .privileged_headers   = &.{},             // (default: &.{}) Stripped when following a redirect to a different domain.
        }); // << Client.RequestOptions{ ... }
      defer req.deinit();
      req.transfer_encoding = .{.content_length= data.len};

      // Send and write the request
      try req.send();
      var W = req.writer();
      try W.writeAll(data);
      try req.finish();
      try req.wait();


      // Test the result
      // try std.testing.expectEqual(req.response.status, .ok);
      // if (req.response.status != .ok) {
      //   var R = req.reader();
      //   const response = try R.readAllAlloc(A, 1024 * 1024 * 4);
      //   defer A.free(response);
      //   prnt("Response:\n{s}\n", .{response});
      // }
    }
  };

};

const secret = struct {
  /// @descr Reads a secret from the first line of the given {@arg file}
  /// @note Caller must free the resulting {@link cstr}
  /// @note Path must be relative to the current folder
  fn read (file :cstr, A :std.mem.Allocator) !cstr {
    const data = try std.fs.cwd().readFileAlloc(A, file, 1024);
    var it = std.mem.splitScalar(u8, data, '\n');
    return it.first();
  }
};

//______________________________________
// @section Entry Point
//____________________________
pub fn main () !void {
  // Configuration
  const hook       = "./bin/discord.hook";
  const lastcommit = "./bin/lastcommit.gman";

  // Start the process
  echo(gman.Prefix++"Running ...");
  var A = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  defer A.deinit();

  // Find the absolute path of the folder we are running from
  const cwd = try std.fs.cwd().realpathAlloc(A.allocator(), ".");
  defer A.allocator().free(cwd);

  // TODO: Extract repository parts from the origin url instead
  const R = git.Repo{
    .name  = std.fs.path.basename(cwd), // TODO: Case of folder name being different than the remote repo name.
    .owner = "heysokam",                // TODO: Case of owner other than the hardcoded one
    .host  = "https://github.com",      // TODO: Case of different git hosting service
  };

  // Run the process
  const list = try gman.commits.pending(lastcommit, gman.commits.FilterTags, A.allocator());
  try discord.commits.send(&list, &R, hook);
  try gman.commits.save(&list, lastcommit);
}
