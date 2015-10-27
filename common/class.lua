
local function init_fn() end

local function new_fn(self, new)
   new = setmetatable(new or {}, self)
   new:init()
   return new
end

return function (name, ...)
   assert(type(name) == "string")
   local Class = {}
   for _, el in ipairs{...} do  -- Copy all derived-froms.
      for k,v in pairs(el) do Class[k] = v end
   end

   Class.__index = Class
   Class.__name  = name

   Class.new  = new_fn
   Class.init = init_fn

   return Class
end
