--  Copyright (C) 27-10-2015 Jasper den Ouden.
--  under the terms of the GNU Affero General Public License

local Expr   = require "el.Expr"
local Var = require "el.Var"

local elementify = require "steps.elementify"

local Lambda = require("common.class")("Lambda", Expr)

function Lambda:init()
   Expr.init(self)

   if not self.args then
      local rawargs = table.remove(self, 1)
      if type(rawargs) == "string" then
         self.lname = rawargs
         rawargs = table.remove(self, 1)
      end
      self.args = {rawargs.name}
      for _, var in ipairs(rawargs) do table.insert(self.args, var) end
   end


   for _,var in ipairs(self.args) do self.scope[var] = Var:new{var, self, {}} end
   for i = 1, #self do
      self[i] = elementify(self[i], self.scope)
   end
end

----- To lua.
local to_lua = require "steps.to_lua"

function Lambda:to_lua()
   local body = {}
   for _, el in ipairs(self) do table.insert(body, to_lua(el)) end
   return string.format("function (%s)\n  %s end",
                        table.concat(self.args, ", "), table.concat(body, "\n  "))
end

----- Typecalc stuff.
function Lambda:typecalc(case, in_tp)
   assert(#in_tp == #args)  -- TODO optionals?

   for i, tp in pairs(in_tp) do  -- Add the option to all the arguments.
      self:var(self.args[i]):typeset(case, tp)
   end

   for _, b in ipairs(self) do
      b:typecalc(base)
   end

   -- TODO collect return cases..
end

return Lambda
