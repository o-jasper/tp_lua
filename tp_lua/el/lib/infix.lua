local to_lua = require "steps.to_lua"

local function infix(name, whole)
   return function (expr) 
      local ret = {}
      for _, v in ipairs(expr) do table.insert(ret, to_lua(v)) end
      return table.concat(ret, whole or string.format(" %s ", name or expr.name))
   end
end

return infix
