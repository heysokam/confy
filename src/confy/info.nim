#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/os
# @deps ndk
import nstd/paths
import nstd/strings
# @deps confy
import ./types
import ./tool/helper
import ./cfg


#_____________________________
const NoValue      = "..."
const InfoTemplate = """
{cfg.prefix}Building {obj.kind} | {obj.trg} in {obj.root}:

  Version:          {version}
  Target Binary:    {obj.trg.string.lastPathPart}
  Target Platform:  {obj.syst.os}
  Target Arch:      {obj.syst.cpu}
  Host Platform:    {getHost().os}
  Host Arch:        {getHost().cpu}
  Compiler:         {obj.cc}
  Flags.cc:         {obj.flags.cc}
  Flags.ld:         {obj.flags.ld}
  Remotes:          {remotes}
  Code Subdir:      {subdir}
  Code file list:   {obj.src}
"""
proc report *(obj :BuildTrg) :void=
  ## Reports information about the BuildTrg object in CLI.
  let version = if obj.version != ""    : obj.version   else: NoValue
  let remotes = if obj.remotes.len > 0  : $obj.remotes  else: NoValue
  let subdir  = if obj.sub.string != "" : $obj.sub      else: NoValue
  echo fmt( InfoTemplate )

