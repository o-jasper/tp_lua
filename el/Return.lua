--  Copyright (C) 27-10-2015 Jasper den Ouden.
--  under the terms of the GNU Affero General Public License

-- Input argument, not filled.

local Return = require("common.class")("Return", require "el.Expr")

Return.return_name = "default"

function Return:init()
   assert(self.scope)

   self.return_name = #self > 1 and self[1] or nil
   assert(type(self.return_name) == "string")
end

local infix = require "el.lib.infix"
function Return:to_lua()
   return string.format("return(%s)", infix(nil, ", ")(self))
end

local typecalc = require "steps.typecalc"

function Return:typecalc(case)
   -- Register that it returned.
   local got = self:var("__return_" .. self.return_name)
   return got:type_pass(case, typecalc(self[1]))
   -- TODO return value should be pointless.
end

return Return
