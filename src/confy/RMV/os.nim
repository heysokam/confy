##__________________________________________________________________
## TODO  :  REMOVE THIS                                             |
## Temporary fix while std/paths is implemented into stable branch  |
##__________________________________________________________________|
## NOTE:                                                            |__
## This file is a copy/paste of tiny pieces of devel/std/os            |
## Avoids having to import stable/std/os and devel at the same time,   |
## which creates nameclashes on linking due to redefined functions.    |
##_____________________________________________________________________|


include system/inclrtl
import ./oscommon
import ./osfiles


when weirdTarget:
  discard
elif defined(windows):
  import winlean
elif defined(posix):
  import posix, times
else:
  {.error: "OS module not ported to your operating system!".}

when not weirdTarget:
  proc c_system(cmd: cstring): cint {.importc: "system", header: "<stdlib.h>".}

  when not defined(windows):
    proc c_free(p: pointer) {.importc: "free", header: "<stdlib.h>".}


when weirdTarget:
  {.pragma: noWeirdTarget, error: "this proc is not available on the NimScript/js target".}
else:
  {.pragma: noWeirdTarget.}

proc exitStatusLikeShell*(status: cint): cint =
  ## Converts exit code from `c_system` into a shell exit code.
  when defined(posix) and not weirdTarget:
    if WIFSIGNALED(status):
      # like the shell!
      128 + WTERMSIG(status)
    else:
      WEXITSTATUS(status)
  else:
    status

proc execShellCmd*(command: string) :int 
    {.rtl, extern: "nos$1", tags: [ExecIOEffect], noWeirdTarget.}=
  ## Executes a `shell command`:idx:.
  ##
  ## Command has the form 'program args' where args are the command
  ## line arguments given to program. The proc returns the error code
  ## of the shell when it has finished (zero if there is no error).
  ## The proc does not return until the process has finished.
  ##
  ## To execute a program without having a shell involved, use `osproc.execProcess`
  result = exitStatusLikeShell(c_system(command))

