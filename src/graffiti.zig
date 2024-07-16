//!:______________________________________________________________________
//! ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU LGPLv3 or later  :
//!:______________________________________________________________________
//!
//! @fileoverview
//!  Automated Git Tag manager
//!  Creates tags for commits that modified an specified version file,
//!  and pushes any pending tags to the remote git repository
//!
//!  @note
//!   It creates tags retroactively.
//!   Its process will apply tags to commits that were never tagged,
//!   but modified the version variable described in the target file.
//!
//!  @todo Usage How-to
//!
//_______________________________________________________________________|
//! @license
//!  Contains code inspired by    github.com/beef331/graffiti    |  MIT  :
//!    (C) Copyright 2023 Jason Beetham
//_______________________________________________________________________|
// @note About github.com/beef331/graffiti reference
//  Their process/ideas were heavily referenced to create this tool.
//  Their code was only lightly referenced for implementation details.
//  - Git commands to run
//  - Process for getting diff files specific for each tag
//  - Extracting `version = ...` modification patterns out of diff files
//  Finding Zig alternatives to those processes was done independently.
//_______________________________________________________________________|
const graffiti = @This();
// @deps std
const std  = @import("std");
// @deps zstd
const zstd = @import("./lib/zstd.zig");
const cstr = zstd.cstr;
const Version = zstd.Version;
const prnt = zstd.prnt;
const echo = zstd.echo;
const fail = zstd.fail;
const git  = zstd.git;


const Error = error { FormatError };
fn getEqPos (content :cstr) !usize {
  return std.mem.lastIndexOf(u8, content, "=") orelse error.FormatError;
}
const version = struct {
  fn pattern (file :cstr) cstr {
    return switch (zstd.Lang.fromFile(file)) {
      .Nim => "version",
      .Zig => "const version",
      else => fail("Unknown pattern for file:  {s}\n", .{file}),
    };
  }

  fn fromFileDiff (file :cstr, diff :cstr) !Version {
    var lines = std.mem.splitScalar(u8, diff, '\n');
    var result :Version= zstd.version(0,0,0);
    while (lines.next()) | line | {
      // Skip early cases
      if (line.len == 0                     ) continue; // Skip empty lines
      if (!std.mem.startsWith(u8, line, "+")) continue; // Skip lines that don't add changes
      if (line.len == 1                     ) continue; // Skip new newlines (start with + and contain nothing else)
      var tmp = line[1..line.len];                      // Remove the first + from the line
      if (!std.mem.startsWith(u8, tmp, graffiti.version.pattern(file))) continue;


      // Start searching from the last = of the line
      const eqPos = graffiti.getEqPos(tmp) catch fail("Incorrect version pattern format for file:  {s}", .{file});
      tmp = tmp[eqPos+1..tmp.len];                         // Get the part of the line that we need
      tmp = std.mem.trim(u8, tmp, " ");                    // Remove leading whitespaces
      if (!std.mem.startsWith(u8, tmp, "\"")) fail("Incorrect version pattern format for file:  {s}", .{file});
      var parts = std.mem.splitScalar(u8, tmp[1..], '\"');  // split by `"` and return the first entry
      result = try Version.parse(parts.first());            // Return the version parsed from the resulting portion of the line
      break;  // If we reached this far, we already found a version and we should return
    }
    return result;
  }

  fn filterList (list :*git.Commit.List, file :cstr) !void {
    var to :usize= 0;
    for (0..list.items.len) | from | {
      list.items[to] = list.items[from]; // Move the items backwards when needed
      // Save items that match the condition: Increment target index by one, so that we don't override this item on the next iteration step
      if (try list.items[to].modified(file, graffiti.version.pattern(file))) to += 1;  // Keep commits that modified the file
    }
    list.shrinkRetainingCapacity(to);
  }
};
/// @descr Removes the commits from the {@arg list} that didn't modify the version pattern inside the {@arg file}
pub fn filter (list :*git.Commit.List, file :cstr) !void { try graffiti.version.filterList(list, file); }

const tag = struct {
  fn from (commit :git.Commit, file :cstr) !git.Tag {
    const hash = try git.diff.file.byHash(file, commit.hash, commit.A);  // Find the diff of the file from this commit to the previous
    const vers = try graffiti.version.fromFileDiff(file, hash);          // Find the version inside the diff
    return git.Tag.fromVersion(vers);                                    // Return the tag for the version we found
  }
};

pub fn write (T :*const git.Tag, commit :*const git.Commit) !void {
  // echo(vers);
  // const tagCommand = "git -C $1 tag -a v$2 $3 -m \"$4\""
  // discard execShellCmd(tagCommand % [parent, version, commit, message])
  var C = zstd.shell.Cmd.create(commit.A);
  defer C.destroy();

  try C.add(git.cmd);
  try C.add(git.tag.cmd.base);
  try C.add("-a");        // Write an annotated tag
  try C.add(try std.fmt.allocPrint(commit.A, "v{}", .{T.version}));  // Add the tag name
  try C.add(commit.hash); // Specify the hash of the commit that will be tagged
  // Make a tag with a message
  try C.add(try std.fmt.allocPrint(commit.A, "-m \"{s}\"", .{commit.msg}));  // Add the commit message to the tag message
  if (commit.body.len > 0) {    // Add the commit body to the tag message
    // Following -m instances will concatenate with the previous as a separate paragraph
    // -m ""      Add an empty line to the message
    // -m "body"  Add the body to the message, wrapped in quotes
    try C.add(try std.fmt.allocPrint(commit.A, "-m \"\" -m \"{s}\"", .{commit.body}));
  }
  try C.exec();
}


//______________________________________
// @section Entry Point
//____________________________
pub fn main() !void {
  echo("graffiti: Running ...");
  var A = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  defer A.deinit();

  var args = try std.process.argsWithAllocator(A.allocator());
  defer args.deinit();
  _ = args.next();              // arg0
  const cli_file = args.next(); // arg1

  const file  = cli_file orelse "confy.nimble";                    // Get the name of the file that contains the version
  var commits = try git.log.commits.forFile(file, A.allocator());  // Get the full list of commits for that file
  try graffiti.filter(&commits, file);                             // Remove the commits that didn't modify the version
  const tags = try git.tag.all(A.allocator());                     // Get list of existing Version tags
  var newTags :usize= 0;
  for (commits.items) | commit | {                                 // For every commit in the repo that modified the version
    const tg = try graffiti.tag.from(commit, file);
    if (git.Tag.list_contains(&tags, &tg)) continue;               // Skip version tags that already exist
    try graffiti.write(&tg, &commit);                              // Ask git to write the tag into the corresponding commit
    newTags += 1;
  }
  if (newTags == 0) { echo("graffiti: No tags to write."); return; }
  try git.tag.push(A.allocator());
  echo("graffiti: Done.");
}

