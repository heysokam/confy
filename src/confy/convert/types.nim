#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/tables
import std/sets
# Confy dependencies
import ../types


#_______________________________________
# Code Generator Types
#___________________
type Src          * = Fil                      # Source code file
type Target       * = Fil                      # Output target file
type SourceSet    * = HashSet[Src]             # Many sources
type TargetSet    * = HashSet[Target]          # Many targets
type DirSet       * = HashSet[Dir]             # Many Dirs
type SourcesTable * = Table[Src, TargetSet]    # One src with many targets
type TargetsTable * = Table[Target, SourceSet] # One trg with many sources
type DirsTable    * = Table[Dir, SourceSet]    # One dir with many sources
type GlobsTable   * = Table[Dir, SourceSet]    # One dir with many globbed sources
type CodeTree *{.inheritable.}= object
  trg   *:Fil
  code  *:DirsTable  # Table[Dir, SourceSet]
type GlobTree  * = object of CodeTree
type DiffTree  * = object of CodeTree
type BuildCode * = tuple[trees:seq[CodeTree], globs:seq[GlobTree], diffs:seq[DiffTree]]

