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

local check_name = require "dromozoa.dom.check_name"

local metatable = {}

function metatable:__newindex(k, v)
  if type(k) == "string" then
    check_name(k)
  end
  rawset(self, k, v)
end

function metatable:__call(t)
  for k, v in pairs(t) do
    self[k] = v
  end
  return self
end

return setmetatable({}, {
  __call = function (_, name)
    return setmetatable({ [0] = check_name(name) }, metatable)
  end;
})
