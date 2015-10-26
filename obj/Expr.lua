--  Copyright (C) 27-10-2015 Jasper den Ouden.
--  under the terms of the GNU Affero General Public License

local Expr = require("common.class")("Expr")

function Expr:init()
   --for k,v in pairs(self) do print(k,v) end
   assert(self.scope)
end

function Expr:var(name)
   local scope, got = self.scope, nil
   while scope and not got do
      got = scope[name]
      scope = scope.parent
   end
   return got
end

local function infix(name, whole)
   return function (expr) 
      local ret = {}
      for _, v in ipairs(expr) do table.insert(ret, to_lua(v)) end
      return table.concat(ret, whole or string.format(" %s ", name or expr.name))
   end
end

----- To lua.

local function to_lua(expr)
   if type(expr) == "table" and not expr.to_lua then
      print("HRM")
      for k,v in pairs(expr) do print(k,v) end
      print(expr.__name)
   end
   return type(expr) == "table" and expr:to_lua() or tostring(expr)
end

local function infix(name, whole)
   return function (expr) 
      local ret = {}
      for _, v in ipairs(expr) do table.insert(ret, to_lua(v)) end
      return table.concat(ret, whole or string.format(" %s ", name or expr.name))
   end
end

local handlers = {}

-- All the infix ops. (lazy; currently all being parenthesis-surrounded)
local function the_infix(expr) return "(" .. infix()(expr) .. ")" end
for _, v in pairs({"+", "-", "*", "/", "%", "<", "<=", ">=", "~=", "or", "and"}) do
   handlers[v] = the_infix
end

function handlers.call(expr)
   if expr[1] == "string" then  -- It is just a hidden "direct" function call.
      local new = {name = expr[1]}
      for i = 2, #expr do new[i - 1] = expr[i] end
      return Expr:new(new):to_lua()
   elseif expr[1].__name == "Lambda" then  -- Expandable.
      local ret = {"if true then"}
      local fun = expr[1]
      for i,var in ipairs(fun.args) do
         table.insert(ret, string.format("local %s = %s", var, to_lua(expr[i + 1])))
      end
      for _, el in ipairs(fun) do
         table.insert(ret, to_lua(el))
      end
      return table.concat(ret, "\n  ") .. "\nend"
   else  -- Is what it is.
      local list = {}
      for i = 2, #expr do
         table.insert(list, to_lua(expr[i]))
      end
      return to_lua(expr[1]) .. "(" .. infix(nil, ", ")(list) .. ")"
   end
end

function handlers.str(expr)
   assert(type(expr[1]) == "string")
   return (expr.s or "\"") .. expr[1] .. (expr.e or expr.s or "\"")
end

function Expr:to_lua()
   if handlers[self.name] then
      return handlers[self.name](self)
   else
      assert(self.name == "return" or self:var(self.name),
             string.format("Dont have %s available in scope", self.name))
      return string.format("%s(%s)", self.name, infix(nil, ", ")(self))
   end
end

return Expr
