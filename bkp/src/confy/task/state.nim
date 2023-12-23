#:_____________________________________________________
#  confy  |  Copyright (C) Ivan Mar (sOkam!)  |  MIT  :
#:_____________________________________________________
# std dependencies
import std/sets
# confy dependencies
import ./base
import ./package as pkg
import ./keywords

#___________________
let package     *:Package=             pkg.getInfo()
var keywordList *:OrderedSet[string]=  keywords.getList()
var taskList    *:OrderedSet[Task]=    sets.initOrderedSet[Task]()

