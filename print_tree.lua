
local function list_tree(x, prep, onto)
   onto = onto or {}
   prep = prep or ""
   if type(x) == "table" then
      --assert(x.name, string.format("no name? %s", x))
      x.name = x.name or "MIAUW"
      if not onto.dont_mark_lines and x.ln then  -- Mark lines
         table.insert(onto, string.format("%s%s  ;L%dC%d", prep, x.name, x.ln, x.ch))
      else
         table.insert(onto, prep .. x.name)
      end
      for i, el in ipairs(x) do
         list_tree(el, prep .. "  ", onto)
      end
   else
      table.insert(onto, prep .. tostring(x))
   end
   return onto
end

local function str_tree(x) return table.concat(list_tree(x), "\n") end
local function print_tree(x) print(table.concat(list_tree(x), "\n")) end

return print_tree, str_tree, list_tree
