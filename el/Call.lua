local Call = require("common.class")("Call", require "el.Expr")

local to_lua = require "steps.to_lua"

function Call:to_lua()
   if self[1] == "string" then  -- It is just a hidden "direct" function call.
      error("Should have been dealt with in absorbtion?")
      local new = {name = self[1]}
      for i = 2, #self do new[i - 1] = self[i] end
      return Self:new(new):to_lua()
   elseif self[1].__name == "Lambda" then  -- Expandable.
      local ret = {"if true then"}
      local fun = self[1]
      for i,var in ipairs(fun.args) do
         table.insert(ret, string.format("local %s = %s", var, to_lua(self[i + 1])))
      end
      for _, el in ipairs(fun) do
         table.insert(ret, to_lua(el))
      end
      return table.concat(ret, "\n  ") .. "\nend"
   else  -- Is what it is.
      local list = {}
      for i = 2, #self do
         table.insert(list, to_lua(self[i]))
      end
      return to_lua(self[1]) .. "(" .. infix(nil, ", ")(list) .. ")"
   end
end

local typecalc = require "steps.typecalc"

function Call:typecalc(case)
   local input = {}
   for i = 2, #self do
      --print(i, self[i], type(self[i]) == "table" and self[i].name)
      table.insert(input, self[i])
   end
   local out_tp = self[1]:typecalc(case, input)
   self.cases[case] = out_tp
   return out_tp
end

return Call
