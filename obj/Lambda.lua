--  Copyright (C) 27-10-2015 Jasper den Ouden.
--  under the terms of the GNU Affero General Public License

local Expr   = require "obj.Expr"
local Lambda = require("common.class")("Lambda", Expr)

function Lambda:init()
   Expr.init(self)

   self.applications = {}

   assert(self.args)
end

-- TODO mess.
function Lambda:apply(args)
   local app = { scope = { parent = self.scope } }
   for i, var in ipairs(self.args) do  -- Fill out the values.
      app.scope[var] = args[i]
   end

   table.insert(self.applications, app)
end

local function to_lua(expr)
   return type(expr) == "table" and expr:to_lua() or  tostring(expr)
end

function Lambda:to_lua()
   local body = {}
   for _, el in ipairs(self) do table.insert(body, to_lua(el)) end
   return string.format("function (%s)\n  %s end",
                        table.concat(self.args, ", "), table.concat(body, "\n  "))
end

return Lambda
