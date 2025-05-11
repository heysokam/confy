#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________

#_______________________________________
# @section Compiler Config
#_____________________________
const debug  *{.booldefine.}=  not (defined(release) or defined(danger)) or defined(debug)


#_______________________________________
# @section Tool Config
#_____________________________
const tool_name    *{.strdefine .}= "confy"
const tool_icon    *{.strdefine .}= "ᛝ"
const tool_sep     *{.strdefine .}= "|"
const tool_postfix *{.strdefine .}= ":"
const tool_prefix  *{.strdefine .}= cfg.tool_icon&" "&cfg.tool_name&cfg.tool_postfix
const tool_verbose *{.booldefine.}= cfg.debug
const tool_quiet   *{.booldefine.}= false
const tool_force   *{.booldefine.}= false


#_______________________________________
# @section Logging Config
#_____________________________
const log_info  *{.strdefine.}= ""
const log_warn  *{.strdefine.}= " ⚠ Warning ⚠"
const log_error *{.strdefine.}= " ❌ Error ❌"
const log_fatal *{.strdefine.}= " ⛔ Error ⛔"
const log_debug *{.strdefine.}= " 🐜 Debug 🐜"


#_______________________________________
# @section Default Values
#_____________________________
# defaults.dirs
const dirs_bin    *{.strdefine.}= "bin"
const dirs_src    *{.strdefine.}= "src"
const dirs_lib    *{.strdefine.}= ".lib"
const dirs_cache  *{.strdefine.}= ".cache"
const dirs_tests  *{.strdefine.}= "tests"
# defaults.zig
const zig_dir     *{.strdefine.}= ".zig"
const zig_name    *{.strdefine.}= "zig"
const zig_bin     *{.strdefine.}= cfg.zig_name
const zig_cc      *{.strdefine.}= cfg.zig_name&"cc"
const zig_cpp     *{.strdefine.}= cfg.zig_name&"cpp"
const zig_ar      *{.strdefine.}= cfg.zig_name&"ar"
# defaults.nim
const nim_dir     *{.strdefine.}= ".nim"
const nim_name    *{.strdefine.}= "nim"
const nim_bin     *{.strdefine.}= cfg.nim_name
# defaults.nimble
const nimble_dir  *{.strdefine.}= ".nimble"
const nimble_name *{.strdefine.}= "nimble"
const nimble_bin  *{.strdefine.}= cfg.nimble_name
# defaults.git
const git_bin     *{.strdefine.}= "git"

