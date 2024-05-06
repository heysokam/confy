# Created from folder {ROOTDIR} with command:
#   make {MAKE_CMD}
confy.cfg.binDir  = {BINDIR}
confy.cfg.srcDir  = {SRCDIR}
let {NAME} * = {BUILD_KIND}.new(
  src   = {SRC}
  trg   = {TRG}
  syst  = {SYST}
  sub   = {SUBDIR}
  flags = {FLAGS}
  ) # << {BUILD_KIND}.new( ... )
