--  Copyright (C) 27-10-2015 Jasper den Ouden.
--  under the terms of the GNU Affero General Public License

-- Input argument, not filled.

local Var = require("common.class")("Var")

function Var:init()
   if self[1] then
      self.name = self[1]
   end
   if self[2] then
      self.occurances = self[2]
   end
   while #self > 0 do table.remove(self) end

   assert(type(self.name) == "string")
   assert(type(self.occurances) == "table")
end

function Var:to_lua()
   return self.name
end

return Var
