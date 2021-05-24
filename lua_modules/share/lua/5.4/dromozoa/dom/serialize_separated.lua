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

return function (self, sep)
  local buffer = {}
  for i = 1, #self do
    local v = self[i]
    local t = type(v)
    if t == "number" then
      buffer[i] = ("%.17g"):format(v)
    elseif t == "string" then
      buffer[i] = v
    elseif t == "table" then
      local metatable = getmetatable(v)
      if metatable and metatable["dromozoa.dom.is_serializable"] then
        buffer[i] = tostring(v)
      end
    end
  end
  return table.concat(buffer, sep)
end
