--  Copyright (C) 27-10-2015 Jasper den Ouden.
--  under the terms of the GNU Affero General Public License

local Expr   = require "el.Expr"
local Var = require "el.Var"

local elementify = require "steps.elementify"

local Lambda = require("common.class")("Lambda", Expr)

Lambda.lambda_name = "default"

function Lambda:init()
   Expr.init(self)

   if not self.args then
      local rawargs = table.remove(self, 1)
      if type(rawargs) == "string" then
         self.lambda_name = rawargs
         rawargs = table.remove(self, 1)
      end
      self.args = {rawargs.name}
      for _, var in ipairs(rawargs) do table.insert(self.args, var) end
   end

   for _,var in ipairs(self.args) do
      self.scope[var] = Var:new{var, self, {}, scope=self.scope}
   end
   self.scope["__return_" .. self.lambda_name] = self

   for i = 1, #self do
      self[i] = elementify(self[i], self.scope)
   end

   self.returned_here = {}
end

----- To lua.
local to_lua = require "steps.to_lua"

function Lambda:to_lua()
   local body = {}
   for _, el in ipairs(self) do table.insert(body, to_lua(el)) end
   return string.format("function (%s)\n  %s end",
                        table.concat(self.args, ", "), table.concat(body, "\n  "))
end

local function tp_or_combine(x)  -- TODO lazy.
   return #x > 1 and Tp:new("any") or x[1]
end

----- Typecalc stuff.
function Lambda:type_pass(case, in_tp)  -- This collects return cases.
   local list = self.returned_here[case] or {}
   if #list == 0 then self.returned_here = list end
   table.insert(list, in_tp)
end

local typecalc = require "steps.typecalc"

function Lambda:typecalc(case, input)
   assert(#input == #self.args)  -- TODO optionals?

   local here = {}
   self.returned_here[case] = here

   for i, e in ipairs(input) do  -- Add the type to all the arguments.
      self:var(self.args[i]):type_pass(case, e)
   end

   for _, b in ipairs(self) do typecalc(self, b, case) end

   self.cases[case] = tp_or_combine(here)

   return self.cases[case]
end

return Lambda
