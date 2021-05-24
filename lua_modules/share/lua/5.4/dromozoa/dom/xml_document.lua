-- Copyright (C) 2017,2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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
local serialize_xml = require "dromozoa.dom.serialize_xml"

local super = document
local class = {}
local metatable = { __index = class }

function class:serialize(out)
  out:write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
  local stylesheets = self.stylesheets
  if stylesheets then
    for i = 1, #stylesheets do
      serialize_xml(out, stylesheets[i], true)
    end
  end
  self:serialize_doctype(out)
  serialize_xml(out, self[1])
end

return setmetatable(class, {
  __index = super;
  __call = function (_, root)
    return setmetatable({ root }, metatable)
  end;
})
