--  Copyright (C) 27-10-2015 Jasper den Ouden.
--  under the terms of the GNU Affero General Public License

local Expr   = require "el.Expr"
local Call   = require "el.Call"
local Str    = require "el.Str"
local Return = require "el.Return"

local function elementify(new, scope)
   scope = scope or require "el.virtual.default_scope"

   if type(new) == "table" then
      if new.name == "lambda" then  -- Function definition or creation of variables.
         new.scope={ parent = new.scope or scope }
         return require("el.Lambda"):new(new)
      elseif new.name == "exp" then  -- Use next object for macro expansion.
         new.scope = scope
         local mac = elementify(table.remove(new, 1))
         mac.scope = scope
         return elementify(mac:apply(new))
      elseif new.name == "str" then  -- Direct string
         return Str:new(new)
      else
         if new.name == "call" then  -- Calls that are direct, make them as usual.
            if type(new[1]) == "string" then
               new.name = new[1]
               table.remove(new, 1)
            end
         end

         new.scope = scope

         for i = 1, #new do new[i] = elementify(new[i], new.scope) end

         local new_from = ({ call=Call, ["return"]=Return })[new.name]
         return (new_from or Expr):new(new)
      end
   elseif type(new) == "string" then
      if tonumber(new) then
         return tonumber(new)
      end
      local scope, got = scope, nil
      while scope and not got do
         got = scope[new]
         scope = scope.parent
      end
      assert(got, string.format("Couldnt find variable; '%s'", new))
      return got
   else
      return new
   end
end

return elementify
