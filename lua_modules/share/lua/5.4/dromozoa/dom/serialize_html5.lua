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

local escape_table = {
  ["&"] = "&amp;";
  ["\""] = "&quot;";
  ["<"] = "&lt;";
  [">"] = "&gt;";
}

local nbsp = string.char(0xC2, 0xA0) -- U+00A0 NO-BREAK SPACE

local void_elements = {
  area = true;
  base = true;
  br = true;
  col = true;
  embed = true;
  hr = true;
  img = true;
  input = true;
  keygen = true; -- removed from HTML 5.2
  link = true;
  menuitem = true; -- removed from HTML 5.2
  meta = true;
  param = true;
  source = true;
  track = true;
  wbr = true;
}

local function serialize_html5(out, u)
  local name = u[0]

  local keys = {}
  local n = 0
  local m = 0
  for k in pairs(u) do
    local t = type(k)
    if t == "number" then
      if m < k then
        m = k
      end
    elseif t == "string" then
      n = n + 1
      keys[n] = k
    end
  end
  table.sort(keys)

  out:write("<", name)
  for i = 1, n do
    local k = keys[i]
    local v = u[k]
    if v == true then
      out:write(" ", k)
    else
      local t = type(v)
      if t == "number" then
        out:write(" ", k, "=\"", ("%.17g"):format(v), "\"")
      elseif t == "string" then
        out:write(" ", k, "=\"", (v:gsub("[&\"]", escape_table):gsub(nbsp, "&nbsp;")), "\"")
      elseif t == "table" then
        local metatable = getmetatable(v)
        if metatable and metatable["dromozoa.dom.is_serializable"] then
          out:write(" ", k, "=\"", (tostring(v):gsub("[&\"]", escape_table):gsub(nbsp, "&nbsp;")), "\"")
        end
      end
    end
  end
  out:write ">"

  if not void_elements[name] then
    for i = 1, m do
      local v = u[i]
      local t = type(v)
      if t == "number" then
        out:write(("%.17g"):format(v))
      elseif t == "string" then
        out:write((v:gsub("[&<>]", escape_table):gsub(nbsp, "&nbsp;")))
      elseif t == "table" then
        serialize_html5(out, v)
      end
    end
    out:write("</", name, ">")
  end
end

return serialize_html5
