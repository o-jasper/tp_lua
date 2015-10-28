--  Copyright (C) 27-10-2015 Jasper den Ouden.
--  under the terms of the GNU Affero General Public License

-- Input argument, not filled.

local Return = require("common.class")("Return", require "el.Expr")

function Return:init()
   assert(self.scope)
end

local infix = require "el.lib.infix"
function Return:to_lua()
   return string.format("return(%s)", infix(nil, ", ")(self))
end

return Return
