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

local utf8 = require "dromozoa.utf8"
local is_name_char = require "dromozoa.dom.is_name_char"
local is_name_start_char = require "dromozoa.dom.is_name_start_char"

return function (name)
  for p, c in utf8.codes(name) do
    if p == 1 then
      if not is_name_start_char(c) then
        error(("invalid character #x%X at position %d"):format(c, p))
      end
    else
      if not is_name_char(c) then
        error(("invalid character #x%X at position %d"):format(c, p))
      end
    end
  end
  return name
end
