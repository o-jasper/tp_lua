
local function to_lua(expr)
   if type(expr) == "table" and not expr.to_lua then
      print("HRM")
      for k,v in pairs(expr) do print(k,v) end
      print(expr.__name)
   end
   return type(expr) == "table" and expr:to_lua() or tostring(expr)
end

return to_lua
