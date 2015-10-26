local Parser = require "parse.Parser"
local print_tree = require "print_tree"

local p = Parser:new()

print_tree(p:parse("2 (4 352(352 23523 {53 343}))"))

print_tree({head="423", 1,2,{head="4",3,4},5})
