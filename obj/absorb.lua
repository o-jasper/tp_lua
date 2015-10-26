--  Copyright (C) 27-10-2015 Jasper den Ouden.
--  under the terms of the GNU Affero General Public License

local Expr = require "obj.Expr"
local Lambda  = require "obj.Lambda"
local Var = require "obj.Var"

local function absorb(new, scope)
   if type(new) == "table" then
      if new.name == "lambda" then  -- Function definition or creation of variables.
         local scope = { parent = new.scope or scope }
         local rawargs = table.remove(new, 1)
         local args = {rawargs.name}
         for _, var in ipairs(rawargs) do table.insert(args, var) end
         
         local ret = Lambda:new({ args = args, scope=scope })

         for _,var in ipairs(args) do scope[var] = Var:new{var, ret, {}} end
         for _, el in ipairs(new)  do table.insert(ret, absorb(el, scope)) end

         return ret
      elseif new.name == "exp" then  -- Use next object for macro expansion.
         new.scope = scope
         local mac = absorb(table.remove(new, 1))
         mac.scope = scope
         return absorb(mac:apply(new))
      elseif new.name == "str" then  -- Direct string
         return Expr:new(new)
      else -- Function call.
         new.scope = scope

         for i = 1, #new do
            new[i] = absorb(new[i], new.scope)
         end
         return Expr:new(new)
      end
   elseif type(new) == "string" then
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

return absorb
