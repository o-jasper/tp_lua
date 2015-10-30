--  Copyright (C) 27-10-2015 Jasper den Ouden.
--  under the terms of the GNU Affero General Public License

local Op = require("common.class")("Op", require "el.Expr")
function Op:init() end

local Tp = require "tp.Tp"

local Public = {}
   
Public["+"] = Op:new{name="+"}
Public["+"].typecalc = function(self, case, in_type)
   return Tp:new{name="plusresult"}  -- TODO
end

Public["*"] = Op:new{name="*"}
Public["*"].typecalc = function(self, case, in_type)
   return Tp:new{name="timesresult"}  -- TODO
end

return Public
