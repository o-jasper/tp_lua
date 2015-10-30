local elementify = require "steps.elementify"
local typecalc   = require "steps.typecalc"
local p          = require("parse.Parser"):new{name="call"}
local print_tree = require "print_tree"

local function to_lua(expr)
   return elementify(expr, {}):to_lua()
end

local tc_cnt = 0

local function ptl(str) 
   local expr = p:parse("s " .. str)
   expr = elementify(expr[2])
   --print_tree(expr)
   tc_cnt = tc_cnt + 1
   local tp = typecalc(expr, nil, tc_cnt)
   print("->", tp)
   print_tree(tp)
end

ptl "2"

ptl [[(call (lambda(q) (return 1)) 3)]]

ptl [[(call (lambda(a b) (return (+ a b))) 1 2)]]

--ptl [[(call (lambda(a b sqr) (return (sqr (+ a b))))
-- 1 2
-- (lambda (x) (return (* x x))))
--]]

