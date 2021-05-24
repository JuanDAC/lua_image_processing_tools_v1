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

local class = {}

function class:serialize_doctype(out)
  local doctype = self.doctype
  if doctype then
    out:write("<!DOCTYPE ", doctype.name)
    local public_id = doctype.public_id
    local system_id = doctype.system_id
    if public_id then
      out:write(" PUBLIC \"", public_id, "\"")
    end
    if system_id then
      if not public_id then
        out:write " SYSTEM"
      end
      out:write(" \"", system_id, "\"")
    end
    out:write ">"
  end
end

return class
