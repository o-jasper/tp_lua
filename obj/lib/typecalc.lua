local Tp = require "tp.Tp"

local function typecalc(self, e, case)
   local etp = type(e)
   if etp == "table" then
      return e:typecalc(case)
   elseif etp == "string" then
      return self:var(e):typecalc(case)
   else
      return Tp:new{name="eql", e}
   end
end

return typecalc
