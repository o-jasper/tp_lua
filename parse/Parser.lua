--  Copyright (C) 22-10-2015 Jasper den Ouden.
--  under the terms of the GNU Affero General Public License

local string_split = require "common.string_split"

-- Find in any of a list.
local function find(list, pat)
   for ln, el in pairs(list) do
      local _ ,ch = string.find(el, pat, 1, true)
      if ch then
         return ch, ln
      end
   end
   return nil, nil
end
 
-- Figure the next step.
local function upnext(list, begin_pat, end_pat)
   local ret = nil
   for _, pat in pairs(begin_pat) do
      local ch, ln = find(list, pat)
      if ln and (not ret or ln < ret.ln or (ln == ret.ln and ch < ret.ch)) then
         ret = {ln = ln, ch = ch, begin = true, pat=pat}
      end
   end
   for j, pat in pairs(end_pat) do
      local ch, ln = find(list, pat)
      if ln and (not ret or ln < ret.ln or (ln == ret.ln and ch < ret.ch)) then
         ret = {ln = ln, ch = ch, begin = false, pat=pat}
      end
   end
   return ret
end

local Parser = require("common.class")("Parser")

function Parser:init() end

function Parser:parse(str)
   return self:parse_list(string_split(str, "\n"))
end

local function parse_error(got, str, ...)
   error(string.format("E:Parse #Ln%d #CH%d,\n  %s", ret.ln, ret.ch,
                       string.format(str, ...)))
end

-- Whitespace splits.
local function wsp_split(str, into) 
   into = into or {}
   for _, el in ipairs(string_split(str, "[ \t]+", false)) do
      if el ~= "" then
         table.insert(into, tonumber(el) or el)
      end
   end
   return into
end

Parser.beginners = {"(", "[", "{"}
Parser.enders    = {")", "]", "}"}
Parser.disallowed = {}

local set = {}
Parser.sub = set

Parser.beginner = "("
Parser.ender = ")"
Parser.disallowed = {}
Parser.only_end = ")"

Parser.name = false

set["("] = Parser:new{}
set["["] = Parser:new({
   name="[",
   beginner = "[",
   ender = "]",
   beginners = Parser.beginners, enders = Parser.enders,
   disallowed = {}, only_end = "]",
})
set["{"] = Parser:new({
   name = "{",
   beginner = "{",
   ender = "}",
   beginners = Parser.beginners, enders = Parser.enders,
   disallowed = {}, only_end = "}",
})

function Parser:parse_list(list, ch, ln)
   local ret, ch, ln = {}, ch or 0, ln or 0
   while #list > 0 do
      -- TODO strip comments first.
      local got = upnext(list, self.beginners, self.enders)
      if got then
         -- Beginning/ending of this kind barred.
         if self.disallowed[got.beginner] or 
            (self.only_end and got.beginner ~= self.only_end and not self.beginner) then
            parse_error("Disallowed %s from %s(%s): %s",
                        got.beginner and "beginning" or "ending",
                        self.name, self.beginner, got.beginner)
         end
         while ln + 1 < got.ln do  -- Everything from inbetween.
            wsp_split(list[1], ret)
            table.remove(list, 1)
            ln = ln + 1
            ch = 0
         end

         wsp_split(string.sub(list[1], 1, got.ch - #got.pat), ret)
         list[1] = string.sub(list[1], got.ch + 1)  -- TODO character count off.
         ch = ch + got.ch
         if got.begin then
            --local subret, remaining, a_ch, a_ln =
            local subret, pre_ch = nil, ch
            subret, list, ch, ln = self.sub[got.pat]:parse_list(list, ch, ln)
            subret.ln = ln + 1
            subret.ch = pre_ch
            table.insert(ret, subret) -- Add the sublist.
         else  -- It is an ending, grab all the stuff.
            if self.name then
               ret.name = self.name
            else -- First one is name.
               ret.name = ret[1]
               table.remove(ret, 1)
            end
            assert(ret.name)
            return ret, list, ch, ln
         end
      else -- Nothing next, tokenize all.
         while #list > 0 do
            wsp_split(list[1], ret)
            table.remove(list)
         end
         ret.name = ret.name or "none"
         return ret, {}, 0, ln
      end
   end
   ret.name = ret.name or "ran_out"
   return ret, {}, 0, ln
end

return Parser

--function write_exp_list(expr)
--   if type(expr) == "table" then
--      local ret = {"(" .. expr.name}
--      for _, el in ipairs(expr) do
--         for _, sel in ipairs(write_expr_list(el)) do table.insert(ret, " " .. sel) end
--      end
--      ret[#ret] = ret[#ret] .. ")"
--      return ret
--   else
--      return {tostring(expr)}
--   end
--end
--
--function write_expr_str(expr) return table.concat(write_expr_list(expr), "") end
