#:______________________________________________________________________
#  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
#:______________________________________________________________________
##! @fileoverview Confy's Git Management tools
#______________________________________________|
from std/strformat import fmt

#_______________________________________
# @section Comptime Defaults
#_____________________________
const git_baseURL *{.strdefine.}= "https://github.com"
const git_owner   *{.strdefine.}= "UndefinedOwner"
const git_repo    *{.strdefine.}= "UndefinedRepository"


#_______________________________________
# @section Git Info: Types
#_____________________________
type Info * = object
  ## @descr Describes metadata/information about a Git repository, and provides tools to manage it.
  baseURL  *:string=  git_baseURL
  owner    *:string=  git_owner
  repo     *:string=  git_repo


#_______________________________________
# @section Git Info: Helpers
#_____________________________
const Templ_GitInfo * = "{info.baseURL}/{info.owner}/{info.repo}"
func `$` *(info :git.Info; templ :static string= Templ_GitInfo) :string= fmt( templ )
  ## @descr Converts the given git {@arg info} object into its corresponding URL

