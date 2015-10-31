local elementify = require "steps.elementify"
local to_lua     = require "steps.to_lua"
local p          = require("parse.Parser"):new{name="call"}
local print_tree = require "print_tree"

local function ptl(str) 
   local expr = p:parse("s " .. str)
   expr = elementify(expr[2])
--   print_tree(expr)
   print(to_lua(expr))
end

ptl "1"

ptl [[(call (lambda(a b) (return (+ a b))) 1 2)]]

ptl [[(call (lambda(a b sqr) (return (sqr (+ a b))))
 1 2
 (lambda (x) (return (* x x))))
]]

