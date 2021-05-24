-- Copyright (C) 2017 Tomoyuki Fujimori <moyu@dromozoa.com>
--
-- This file is part of dromozoa-dom.
--
-- dromozoa-dom is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dromozoa-dom is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-dom.  If not, see <http://www.gnu.org/licenses/>.

local document = require "dromozoa.dom.document"
local serialize_html5 = require "dromozoa.dom.serialize_html5"

local super = document
local class = {}
local metatable = { __index = class }

function class:serialize(out)
  self:serialize_doctype(out)
  serialize_html5(out, self[1])
end

return setmetatable(class, {
  __index = super;
  __call = function (_, root)
    return setmetatable({ doctype = { name = "html" }, root }, metatable)
  end;
})
