return function (name, ...)
   assert(type(name) == "string")
   local Class = {}
   for _, el in ipairs{...} do  -- Copy all derived-froms.
      for k,v in pairs(el) do Class[k] = v end
   end

   Class.__index = Class
   Class.__name  = name

   Class.new = function(self, new)
      new = setmetatable(new or {}, self)
      new:init()
      return new
   end
   return Class
end
