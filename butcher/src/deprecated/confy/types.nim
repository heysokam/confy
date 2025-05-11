
#_______________________________________
# @section Paths
#___________________
type DirFile * = object
  ## @descr Internal Data Type for a single file, so that dir can be adjusted separately without issues.
  ## @field dir Absolute folder where the file is stored
  ## @field file Always relative to {@link:field dir}
  dir   *:Dir
  file  *:Fil

