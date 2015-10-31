local function string_split(str, split_by, simple, into)
   into = into or {}
   simple = simple == nil or simple
   split_by = split_by or " "
   local f, t
   while true do
      pt = (t or 0) + 1
      f,t = string.find(str, split_by, pt, simple)
      if f then
         table.insert(into, string.sub(str, pt, f - 1))
      else
         table.insert(into, string.sub(str, pt))
         return into
      end
   end
end

return string_split
