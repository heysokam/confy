#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  |
#:_____________________________________________________
## Error when loading any files of this module from a non-nimscript source.
## The nims section is completely isolated from confy.
## TODO: Make this check global to confy,
##       and use `when nims` checks inside the proc definitions instead.
#_______________________________________________________________________

const nims = try: gorgeEx("echo").exitCode.bool except: false
  ## Big hack, should be `when defined(nimscript)`, but it seems to fail and this just works.
  ## TODO: Move to a global confy const.

when nims:
  when defined(debug):
    {.warning: "Tried to add a nimscript only module into a binary app.".}
  else:
    {.error: "Tried to add a nimscript only module into a binary app.".}

