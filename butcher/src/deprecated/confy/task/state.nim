#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# @deps std
import std/sets
# @deps confy
import ../types
# @deps confy.task
import ./base
import ./package as pkg
import ./keywords

#___________________
let package     *:Package=             pkg.getInfo()
var keywordList *:OrderedSet[string]=  keywords.getList()
var taskList    *:OrderedSet[Task]=    sets.initOrderedSet[Task]()

