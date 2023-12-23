func isActive *() :bool {.compiletime.}=
  when defined(nimscript): true
  else:
    try: gorgeEx("echo").exitCode.bool except: false
    # @hack Should be just `when defined(nimscript)`, but it seems to fail and this just works.
