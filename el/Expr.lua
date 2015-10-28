--  Copyright (C) 27-10-2015 Jasper den Ouden.
--  under the terms of the GNU Affero General Public License

local Expr = require("common.class")("Expr")

function Expr:init()
   --for k,v in pairs(self) do print(k,v) end
   assert(self.scope)
   self.cases = {}
end

function Expr:var(name)
   local scope, got = self.scope, nil
   while scope and not got do
      got = scope[name]
      scope = scope.parent
   end
   return got
end

----- To lua.
local handlers = {}

local infix = require "el.lib.infix"
-- All the infix ops. (lazy; currently all being parenthesis-surrounded)
local function the_infix(expr) return "(" .. infix()(expr) .. ")" end
for _, v in pairs({"+", "-", "*", "/", "%", "<", "<=", ">=", "~=", "or", "and"}) do
   handlers[v] = the_infix
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

----- Typecalc stuff.
local typecalc = require "steps.typecalc"

function Expr:typecalc(case)
   local si, fun = unpack(self.name == "call" and {2, typecalc(self, self[1], case)}
                             or {1, self:var(self.name)})
   local in_tp = {}
   for i = si, #self do
      table.insert(in_tp, typecalc(self, self[i], case))
   end
   local out_tp = fun:typecalc(case, in_tp)
   self.cases[case] = {in_tp, out_tp}
   return out_tp
end

----- Return.
return Expr
