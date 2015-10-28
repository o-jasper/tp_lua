local elementify = require "steps.elementify"
local p          = require("parse.Parser"):new{name="call"}
local print_tree = require "print_tree"

local function to_lua(expr)
   return elementify(expr, {}):to_lua()
end

local function ptl(str) 
   local expr = p:parse(str)
   expr.name = expr[1]
   table.remove(expr, 1)
--   print_tree(expr)
   print(to_lua(expr))
end

ptl [[call (lambda(a b) (return (+ a b))) 1 2]]

ptl [[call (lambda(a b sqr) (return (sqr (+ a b))))
 1 2
 (lambda (x) (return (* x x)))
]]

