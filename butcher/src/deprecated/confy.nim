
{.warning:"""
The Nim-based confy toolset is deprecated,
and will be removed as soon as the zig rewrite is completed.
""".}

#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
## @fileoverview Cable connector to all modules of the library
import ./confy/types       ; export types
import ./confy/cfg         ; export cfg
import ./confy/dirs        ; export dirs
import ./confy/flags       ; export flags
import ./confy/obj as cObj ; export cObj
import ./confy/builder     ; export builder
import ./confy/tasks       ; export tasks
import ./confy/tools       ; export tools
# @section Forward nstd dependencies to the user's buildsystem code
import nstd/paths   ; export paths
import nstd/strings ; export strings
