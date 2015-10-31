--  Copyright (C) 27-10-2015 Jasper den Ouden.
--  under the terms of the GNU Affero General Public License

local Op = require("common.class")("Op", require "el.Expr")
function Op:init() end

local Tp = require "tp.Tp"

local Public = {}

local function num_rangify(a)
   if a.name == "eql" then
      return (a[1]%1 == 0 and "int" or "num"), a[1], a[1]
   else
      assert(({real=true, int=true})[a.name])
      return a.name, a[1], a[2]
   end
end
local function num_fun_2(a, b, fun)
   local an, af,at = num_rangify(a)
   local bn, bf,bt = num_rangify(b)

   local n, f,t = fun(af, at, bf, bt)
   if f == t then
      return Tp:new{name="eql", f}
   else
      return Tp:new{name=(n or an == "num" and "num" or bn), f, t}
   end
end

local function num_union_2(a, b)
   local function fun(af,at, bf, bt)
      return nil, math.min(af, bf), math.min(at, bt)
   end
   return num_fun_2(a, b, fun)
end

local function num_fun(list, fun)
   while #list > 1 do
      list[2] = num_fun_2(list[1], list[2], fun)
      table.remove(list, 1)
   end
   return list[1]
end

local typecalc = require "steps.typecalc"

local function tps_list(self, case, input)
   local tps = {}
   for i, el in ipairs(input) do
      table.insert(tps, typecalc(self, el, case))
   end
   return tps
end

Public["+"] = Op:new{name="+"}
Public["+"].typecalc = function(self, case, input)
   return num_fun(tps_list(self, case, input),
                  function(af, at, bf, bt) return nil, af + bf, at + bt end)
end

Public["-"] = Op:new{name="-"}
Public["-"].typecalc = function(self, case, input)
   return num_fun(tps_list(input),
                  function(af, at, bf, bt) return nil, af - bt, at - bf end)
end

Public["*"] = Op:new{name="*"}
Public["*"].typecalc = function(self, case, input)
   local function fun(af, at, bf, bt)  -- This is right, right?
      local ff, ft, tf, tt = af*bf, af*bt, at*bf, at*bt
      local f, t = math.min(ff, ft, tf, tt), math.max(ff, ft, tf, tt)

      if (af <= 0 and at >= 0) or (bf <= 0  and bt >= 0) then
         f = math.min(f, 0)
         t = math.max(t, 0)
      end

      return nil , f, t
   end
   return num_fun(tps_list(self, case, input), fun)
end

Public.slot = Op:new{name="slot"}
function Public.slot:typecalc(case, input)
   local obj, slot_key = unpack(tps_list(input))
   assert(obj.name == "table", "Can only access slots from tables.")
   local straight = obj.static[slot_key] or obj.dict
   if straight then
      return straight
   else
      --- TODO in the metatable, access `__index` it is an array, or a function.
   end
end

return Public
