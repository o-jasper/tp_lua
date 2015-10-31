local Str = require("common.class")("Str")

function Str:to_lua()
   assert(type(self[1]) == "string")
   return (self.s or "\"") .. self[1] .. (self.e or self.s or "\"")
end

function Str:typecalc()
   return Tp:new("Str")
end

return Str
