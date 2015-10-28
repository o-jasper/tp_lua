--  Copyright (C) 27-10-2015 Jasper den Ouden.
--  under the terms of the GNU Affero General Public License

local Expr   = require "obj.Expr"
local Lambda = require("common.class")("Lambda", Expr)

function Lambda:init()
   Expr.init(self)

   assert(self.args)
end

----- To lua.
local to_lua = require "obj.lib.to_lua"

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
