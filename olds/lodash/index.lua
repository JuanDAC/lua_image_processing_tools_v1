local try
try = function(try_block)
  local status = true
  local err = nil
  if Utils:is_function(try_block) then
    status, err = xpcall(try_block, debug.traceback)
  end
  local finally
  finally = function(finally_block, catch_block_declared)
    if Utils:is_function(finally_block) then
      finally_block()
    end
    if not catch_block_declared and not status then
      return error(err)
    end
  end
  local catch
  catch = function(catch_block)
    local catch_block_declared = Utils:is_function(catch_block)
    if not status and catch_block_declared then
      local ex = err or "unknown error occurred"
      catch_block(ex)
    end
    return {
      finally = function(finally_block)
        return finally(finally_block, catch_block_declared)
      end
    }
  end
  return {
    catch = catch,
    finally = function(finally_block)
      return finally(finally_block, false)
    end
  }
end
local Utils
do
  local _class_0
  local dbl_quote
  local _base_0 = {
    gt = function(self, value, other, ...)
      value, other = self:cast(value, other)
      if self:is_string(value) or self:is_number(value) then
        return value > other
      elseif self:is_function(value) then
        return value(...) > other(...)
      end
      return false
    end,
    cast = function(self, a, b)
      if type(a) == type(b) then
        return a, b
      end
      local _ = cast
      if self:is_string(a) then
        local cast = self.str
      elseif self:is_boolean(a) then
        local cast = self.bool
      elseif self:is_number(a) then
        local cast = self.num
      elseif self:is_function(a) then
        local cast = self.func
      elseif self:is_table(a) then
        local cast
        do
          local _base_1 = Utils
          local _fn_0 = _base_1.to_table
          cast = function(...)
            return _fn_0(_base_1, ...)
          end
        end
      end
      return a, cast(b)
    end,
    gte = function(self, value, other, ...)
      if self:is_nil(value) or self:is_boolean(value) then
        return value == other
      end
      value, other = self:cast(value, other)
      if self:is_string(value) or self:is_number(value) then
        return value >= other
      elseif self:is_function(value) then
        return value(...) >= other(...)
      elseif self:is_table(value) then
        return false
      end
      return false
    end,
    is_boolean = function(self, value)
      return type(value) == 'boolean'
    end,
    is_empty = function(self, value)
      if self:is_string(value) then
        return #value == 0
      elseif self:is_table(value) then
        local i = 0
        for k, v in Collection:iter(value) do
          i = i + 1
        end
        return i == 0
      else
        return true
      end
    end,
    is_function = function(self, value)
      return type(value) == 'function'
    end,
    is_nil = function(self, value)
      return type(value) == 'nil'
    end,
    is_number = function(self, value)
      return type(value) == 'number'
    end,
    is_string = function(self, value)
      return type(value) == 'string'
    end,
    is_table = function(self, value)
      return type(value) == 'table'
    end,
    args = function(self, value)
      if self:is_table(value) then
        return table.unpack(value)
      else
        return table.unpack({
          value
        })
      end
    end,
    lt = function(self, value, other, ...)
      value, other = self:cast(value, other)
      if self:is_string(value) or self:is_number(value) then
        return value < other
      elseif self:is_function(value) then
        return value(...) < other(...)
      end
      return false
    end,
    lte = function(self, value, other, ...)
      if self:is_nil(value) or self:is_boolean(value) then
        return value == other
      end
      value, other = self:cast(value, other)
      if self:is_string(value) or self:is_number(value) then
        return value <= other
      elseif self:is_function(value) then
        return value(...) <= other(...)
      elseif self:is_table(value) then
        return false
      end
      return false
    end,
    to_func = function(self, ...)
      local t = self:to_table(...)
      return function()
        return self:args(t)
      end
    end,
    to_table = function(self, ...)
      return table.pack(...)
    end,
    to_bool = function(self, value, ...)
      local bool = false
      if self:is_string(value) then
        bool = #value > 0
      elseif self:is_boolean(value) then
        bool = value
      elseif self:is_number(value) then
        bool = value ~= 0
      elseif self:is_function(value) then
        bool = self:to_bool(value(...))
      end
      return bool
    end,
    to_num = function(self, value, ...)
      local num = 0
      if self:is_string(value) then
        local ok = pcall(function()
          num = value + 0
        end)
        if not ok then
          num = math.huge
        end
      elseif self:is_boolean(value) then
        num = value and 1 or 0
      elseif self:is_number(value) then
        num = value
      elseif self:is_function(value) then
        num = self:num(value(...))
      end
      return num
    end,
    to_str = function(self, separator)
      if separator == nil then
        separator = ', '
      end
      return function(value, ...)
        local str = ''
        if self:is_string(value) then
          str = value
        elseif self:is_boolean(value) then
          str = value and 'true' or 'false'
        elseif self:is_nil(value) then
          str = 'nil'
        elseif self:is_number(value) then
          str = value .. ''
        elseif self:is_function(value) then
          str = self:to_str(separator)(value(...))
        elseif self:is_table(value) then
          str = '{'
          for k, v in pairs(value) do
            if self:is_string(v) then
              v = dbl_quote(v)
            else
              v = self:to_str(separator)(v, ...)
            end
            if self:is_number(k) then
              str = tostring(str) .. tostring(v) .. tostring(separator)
            else
              str = tostring(str) .. "[" .. tostring(dbl_quote(k)) .. "]=" .. tostring(v) .. tostring(separator)
            end
          end
          str = tostring(str:sub(0, #str - #separator)) .. "}"
        end
        return str
      end
    end,
    to_string = function(self, ...)
      return self:to_str(', ')(...)
    end,
    array_or_object = function(self, obj)
      local array = false
      local object = false
      tyr(function()
        pairs(obj)
        object = true
      end).catch(function()
        array = true
      end)
      return array, object
    end,
    noop = function(self, ...)
      return nil
    end,
    identity = function(self, ...)
      return ...
    end,
    iter = function(self, p)
      if type(p) == 'function' then
        return p
      end
      return coroutine.wrap(function()
        for i = 1, #p do
          coroutine.yield(p[i])
        end
      end)
    end,
    range = function(self, s, l, step)
      step = step or 1
      if not l then
        l = s
        s = 1
        step = 1
      end
      local t = { }
      for i = s, l, step do
        t[#t + 1] = i
      end
      return t
    end,
    is_equal = function(self, a, b)
      if a == b then
        return true
      elseif type(a) ~= type(b) then
        return false
      elseif type(a) ~= 'table' then
        return false
      end
      local t = { }
      for k, v in pairs(b) do
        t[k] = v
      end
      for k, v in pairs(a) do
        if not mu.is_equal(v, t[k]) then
          return false
        end
        t[k] = nil
      end
      for k, v in pairs(t) do
        return false
      end
      return true
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Utils"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  dbl_quote = function(v)
    return '"' .. v .. '"'
  end
  Utils = _class_0
end
local Function
do
  local _class_0
  local _base_0 = {
    type = "function",
    is_callable = function(self, fn)
      return type(fn) == self.type
    end,
    is_function = function(self, ...)
      return Utils:is_callable(...)
    end,
    after = function(self, n, func)
      local i = 1
      return function(...)
        if Utils:gt(i, n) then
          return func(...)
        end
        i = i + 1
      end
    end,
    ary = function(self, func, n)
      return function(...)
        if n == 1 then
          return func((...))
        else
          local t = Utils:to_table(...)
          local first = Array:take(t, n)
          return func(self:args(first))
        end
      end
    end,
    before = function(self, n, func)
      local i = 1
      local _ = result
      return function(...)
        if Utils:lte(i, n) then
          local result = func(...)
        end
        i = i + 1
        return result
      end
    end,
    modArgs = function(self, func, ...)
      local transforms = { }
      for i, v in ipairs(Utils:to_table(...)) do
        if Utils:is_function(v) then
          Array:push(transforms, v)
        elseif Utils:is_table(v) then
          for k2, v2 in Collection:iter(v) do
            if Utils:is_function(v2) then
              Array:push(transforms, v2)
            end
          end
        end
      end
      return function(...)
        local _ = args
        for i, transform in ipairs(transforms) do
          if Utils:is_nil(args) then
            local args = Utils:to_table(transform(...))
          else
            local args = Utils:to_table(transform(self:args(args)))
          end
        end
        if Utils:is_nil(args) then
          return func(...)
        else
          return func(self:args(args))
        end
      end
    end,
    negate = function(self, func)
      return function(...)
        return not func(...)
      end
    end,
    once = function(self, func)
      local called = false
      local _ = result
      return function(...)
        if not called then
          local result = func(...)
          called = true
        end
        return result
      end
    end,
    rearg = function(self, func, ...)
      local indexes = { }
      for i, v in ipairs(Utils:to_table(...)) do
        if Utils:is_number(v) then
          Array:push(indexes, v)
        elseif Utils:is_table(v) then
          for k2, v2 in Collection:iter(v) do
            if Utils:is_number(v2) then
              Array:push(indexes, v2)
            end
          end
        end
      end
      return function(...)
        local args = Utils:to_table(...)
        local newArgs = { }
        for i, index in ipairs(indexes) do
          Array:push(newArgs, args[index])
        end
        if #indexes == 0 then
          return func(...)
        else
          return func(self:args(newArgs))
        end
      end
    end,
    args = function(self, value)
      if Utils:is_table(value) then
        return table.unpack(value)
      else
        return table.unpack({
          value
        })
      end
    end,
    curry = function(self, f)
      local info = debug.getinfo(f, 'u')
      local docurry
      docurry = function(s, left, ...)
        local ptbl = Array:clone(s)
        local vargs = {
          ...
        }
        for i = 1, #vargs do
          ptbl[#ptbl + 1] = vargs[i]
        end
        left = left - #vargs
        if left > 0 then
          return function(...)
            return docurry(ptbl, left, ...)
          end
        else
          return f(unpack(ptbl))
        end
      end
      return function(...)
        return docurry({ }, info.nparams, ...)
      end
    end,
    curry_closure = function(self, f, n, ...)
      local args = {
        ...
      }
      local cu
      cu = function(...)
        for i, v in ipairs({
          ...
        }) do
          args[#args + 1] = v
        end
        if #args >= n then
          return f(table.unpack(args))
        end
        return cu
      end
      return cu
    end,
    wrap = function(self, f, wr)
      return function(...)
        return wr(f, ...)
      end
    end,
    compose = function(self, ...)
      local fs = {
        ...
      }
      return function(...)
        local args = {
          ...
        }
        for i = #fs, 1, -1 do
          args = {
            fs[i](table.unpack(args))
          }
        end
        return table.unpack(args)
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Function"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Function = _class_0
end
local Math
do
  local _class_0
  local _parent_0 = math
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Math",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Math = _class_0
end
local Number
do
  local _class_0
  local private_NaN, private_INF
  local _base_0 = {
    type = "number",
    get_value = function(self)
      return self.value
    end,
    is_NaN = function(self, value)
      return value == private_NaN
    end,
    is_INF = function(self, value)
      return value == private_INF
    end,
    is_number = function(self, value)
      return type(Number(value)) == self.type
    end,
    to_integer = function(self, value)
      local number = tonumber(value)
      if (Utils:is_NaN(number)) then
        return 0
      end
      if (number == 0 or Utils:is_INF(number)) then
        return number
      end
      return ((function()
        if number > 0 then
          return 1
        else
          return -1
        end
      end)()) * Math.floor(Math.abs(number))
    end,
    in_range = function(self, n, start, stop)
      local _start = Utils:is_nil(stop) and 0 or start or 0
      local _stop = Utils:is_nil(stop) and start or stop or 1
      return n >= _start and n < _stop
    end,
    random = function(self, min, max, floating)
      local minim = Utils:is_nil(max) and 0 or min or 0
      local maxim = Utils:is_nil(max) and min or max or 1
      Math.randomseed(os.clock() * Math.random(os.time()))
      local r = Math.random(minim, maxim)
      if floating then
        r = r + Math.random()
      end
      return r
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, value)
      if (value) then
        self.value = tonumber(value)
      end
    end,
    __base = _base_0,
    __name = "Number"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  private_NaN = 0 / 0
  private_INF = 1 / 0
  Number = _class_0
end
local Array
do
  local _class_0
  local drop_while, find_index, take_while
  local _base_0 = {
    extend = function(self, d, s)
      for k, v in pairs(s) do
        d[k] = v
      end
      return d
    end,
    clone = function(self, array)
      local r = { }
      for i = 1, #array do
        r[#r + 1] = array[i]
      end
      return r
    end,
    call_iteratee = function(self, predicate, selfArg, ...)
      local _ = result
      predicate = predicate or (function()
        local _base_1 = Utils
        local _fn_0 = _base_1.identity
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)()
      if selfArg then
        local result = predicate(selfArg, ...)
      else
        local result = predicate(...)
      end
      return result
    end,
    is_table = function(self, obj)
      return type(obj) == 'table'
    end,
    lowest_value = function(self, a, b)
      return a < b and a or b
    end,
    multiple_inserts = function(self, obj, values)
      for i = 1, #values do
        local value = values[i]
        table.insert(obj, value)
      end
    end,
    convert_to_hash = function(self, obj)
      local output = { }
      for i = 1, #obj do
        local value = obj[i]
        output[value] = true
      end
      return output
    end,
    is_array = function(self, obj)
      if not Utils:is_table(obj) then
        return false
      end
      local i = 0
      for _ in pairs(obj) do
        i = i + 1
        if obj[i] == nil then
          return false
        end
      end
      return true
    end,
    is_empty = function(self, obj)
      return #obj == 0
    end,
    slice = function(self, obj, start, finish)
      if Utils:is_empty(obj) then
        return { }
      end
      local _start = start or 1
      local output = { }
      for i = _start, finish or #obj do
        self:push(output, obj[i])
      end
      return output
    end,
    length = function(self, array)
      return #array
    end,
    len = function(self, ...)
      return self:length(...)
    end,
    index_of = function(self, obj, value)
      for i = 1, #obj do
        if obj[i] == value then
          return i
        end
      end
      return -1
    end,
    includes = function(self, obj, value)
      local index = self:index_of(obj, value)
      if index == -1 then
        return false
      end
      return true
    end,
    reverse = function(self, obj)
      local output = { }
      for i = #obj, 1, -1 do
        table.insert(output, obj[i])
      end
      return output
    end,
    last = function(self, obj)
      return obj[#obj]
    end,
    max = function(self, obj)
      local max = obj[1]
      for i = 2, #obj do
        if obj[i] > max then
          max = obj[i]
        end
      end
      return max
    end,
    min = function(self, obj)
      local min = obj[1]
      for i = 2, #obj do
        if obj[i] < min then
          min = obj[i]
        end
      end
      return min
    end,
    map = function(self, array, callback)
      local _accum_0 = { }
      local _len_0 = 1
      for i = 1, #array do
        _accum_0[_len_0] = callback(array[i], i)
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end,
    map_reverse = function(self, array, callback)
      local _accum_0 = { }
      local _len_0 = 1
      for i = #array, 1, -1 do
        _accum_0[_len_0] = callback(array[i], i)
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end,
    filter = function(self, array, callback)
      local _accum_0 = { }
      local _len_0 = 1
      for i = 1, #array do
        if callback(item, i) then
          _accum_0[_len_0] = item
          _len_0 = _len_0 + 1
        end
      end
      return _accum_0
    end,
    reduce = function(self, obj, callback, memo)
      local initialIndex = 1
      local _memo = memo
      if _memo == nil then
        initialIndex = 2
        _memo = obj[1]
      end
      for i = initialIndex, #obj do
        _memo = callback(_memo, obj[i], i)
      end
      return _memo
    end,
    reduce_right = function(self, obj, callback, memo)
      local initialIndex = #obj
      local _memo = memo
      if _memo == nil then
        initialIndex = initialIndex - 1
        _memo = obj[#obj]
      end
      for i = initialIndex, 1, -1 do
        _memo = callback(_memo, obj[i], i)
      end
      return _memo
    end,
    sum = function(self, obj)
      return self:reduce(obj, function(memo, value)
        return memo + value
      end)
    end,
    concat = function(self, array, ...)
      local output = { }
      self:each(array, function(item)
        return self:push(output, item)
      end)
      local array_others = Utils:to_table(...)
      if self:length(array_others) > 0 then
        self:each(array_others, function(array_current)
          return self:each(array_current, function(item)
            return self:push(output, item)
          end)
        end)
      end
      return output
    end,
    uniq = function(self, obj)
      local output = { }
      local seen = { }
      for i = 1, #obj do
        local value = obj[i]
        if not seen[value] then
          seen[value] = true
          table.insert(output, value)
        end
      end
      return output
    end,
    without = function(self, obj, values)
      local initial_value = { }
      local reducer
      reducer = function(self, accumulator, current)
        if (self:includes(values, current) == false) then
          table.insert(accumulator, current)
        end
        return accumulator
      end
      return self:reduce(obj, reducer, initial_value)
    end,
    some = function(self, obj, callback)
      for i = 1, #obj do
        if callback(obj[i], i) then
          return true
        end
      end
      return false
    end,
    zip = function(self, obj1, obj2)
      local output = { }
      local size = #obj1 > #obj2 and #obj2 or #obj1
      for i = 1, size do
        table.insert(output, {
          obj1[i],
          obj2[i]
        })
      end
      return output
    end,
    every = function(self, obj, callback)
      for i = 1, #obj do
        if not callback(obj[i], i) then
          return false
        end
      end
      return true
    end,
    shallow_copy = function(self, obj)
      local output = { }
      for i = 1, #obj do
        table.insert(output, obj[i])
      end
      return output
    end,
    deep_copy = function(self, value)
      local output = value
      if Utils:is_table(value) then
        output = { }
        for i = 1, #value do
          table.insert(output, self:deep_copy(value[i]))
        end
      end
      return output
    end,
    diff = function(self, obj1, obj2)
      local output = { }
      local hash = self:convert_to_hash(obj2)
      for i = 1, #obj1 do
        local value = obj1[i]
        if not hash[value] then
          table.insert(output, value)
        end
      end
      return output
    end,
    flat = function(self, obj)
      local cb
      cb = function(acc, item)
        if Utils:is_array(item) then
          return self:concat(acc, self:flat(item))
        else
          table.insert(acc, item)
          return acc
        end
      end
      return self:reduce(obj, cb, { })
    end,
    fill = function(self, value, start_or_finish, finish)
      local output = { }
      local item = value
      local start = start_or_finish
      local size = finish
      if finish == nil then
        start = 1
        size = start_or_finish
      end
      for i = start, size do
        output[i] = item
      end
      return output
    end,
    fill_empty = function(self, start_or_finish, finish)
      local output = { }
      local start = start_or_finish
      local size = finish
      if finish == nil then
        start = 1
        size = start_or_finish
      end
      for item = start, size do
        output[item] = item
      end
      return output
    end,
    remove = function(self, obj, callback)
      local output = { }
      local copy = self:deep_copy(obj)
      for i = 1, #copy do
        local value = copy[i]
        if callback(value, i) then
          table.insert(output, value)
          local index = self:index_of(obj, value)
          table.remove(obj, index)
        end
      end
      return output
    end,
    counter = function(self, obj)
      local output = { }
      for i = 1, #obj do
        local value = obj[i]
        output[value] = (output[value] and output[value] or 0) + 1
      end
      return output
    end,
    intersect = function(self, obj1, obj2)
      local output = { }
      local count1 = self:counter(obj1)
      local count2 = self:counter(obj2)
      for k, v in pairs(count1) do
        if count2[k] then
          local new_array = self:fill(k, self:lowest_value(v, count2[k]))
          self:multiple_inserts(output, new_array)
        end
      end
      return output
    end,
    from_pairs = function(self, obj)
      local output = { }
      for i = 1, #obj do
        local item = obj[i]
        output[item[1]] = item[2]
      end
      return output
    end,
    each = function(self, obj, callback)
      return (function()
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, #obj do
          _accum_0[_len_0] = callback(obj[i], i)
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)() and true
    end,
    reverse_each = function(self, obj, callback)
      return (function()
        local _accum_0 = { }
        local _len_0 = 1
        for i = #obj, 1, -1 do
          _accum_0[_len_0] = callback(obj[i], i)
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)() and true
    end,
    chunk = function(self, array, size)
      local t = { }
      size = size == 0 and 1 or size or 1
      local c, i = 1, 1
      while true do
        t[i] = { }
        for j = 1, size do
          self:push(t[i], array[c])
          c = c + 1
        end
        if Utils:gt(c, #array) then
          break
        end
        i = i + 1
      end
      return t
    end,
    push = function(self, array, value)
      return table.insert(array, value)
    end,
    push_new = function(self, array, value)
      local t = Array:slice(array)
      table.insert(t, value)
      return t
    end,
    compact = function(self, array)
      local _accum_0 = { }
      local _len_0 = 1
      for _, item in pairs(array) do
        if item then
          _accum_0[_len_0] = item
          _len_0 = _len_0 + 1
        end
      end
      return _accum_0
    end,
    concat_props = function(self, ...)
      local tmp = Utils:to_table(...)
      local array = { }
      self:each(tmp, function(item)
        array = self:concat(array, item)
      end)
      return array
    end,
    difference = function(self, array, ...)
      local subtracting = self:concat(...)
      return self:filter(array, function(item)
        return not self:includes(subtracting, item)
      end)
    end,
    difference_by = function(self, array, ...)
      local tmp = Utils:to_table(...)
      local iteratee = self:pop(tmp)
      local subtracting = { }
      self:each(tmp, function(item)
        subtracting = self:concat(subtracting, item)
      end)
      local handler
      do
        local _base_1 = Utils
        local _fn_0 = _base_1.identity
        handler = function(...)
          return _fn_0(_base_1, ...)
        end
      end
      if Utils:is_string(iteratee) then
        handler = function(obj)
          return obj[iteratee]
        end
      end
      if Utils:is_function(iteratee) then
        handler = function(...)
          return iteratee(...)
        end
      end
      local minuend = self:map(array, function(item)
        return handler(item)
      end)
      subtracting = self:map(subtracting, function(item)
        return handler(item)
      end)
      return self:filter(array, function(_, index)
        return not self:includes(subtracting, minuend[index])
      end)
    end,
    drop = function(self, array, n)
      n = n or 1
      return self:slice(array, n + 1)
    end,
    shift = function(self, array)
      return table.remove(array, 1)
    end,
    unshift = function(self, p, x)
      table.insert(p, 1, x)
      return p
    end,
    drop_right = function(self, array, n)
      n = n or 1
      return self:slice(array, nil, #array - n)
    end,
    pop = function(self, array)
      return table.remove(array, #array)
    end,
    drop_rightwhile = function(self, array, predicate, selfArg)
      return drop_while(array, predicate, selfArg, #array, -1, true)
    end,
    drop_while = function(self, array, predicate, selfArg)
      return drop_while(array, predicate, selfArg, 1, 1)
    end,
    enqueue = function(self, array, value)
      return table.insert(array, 1, value)
    end,
    fill = function(self, array, value, start, stop)
      start = start or 1
      stop = stop or #array
      for i = start, stop, start > stop and -1 or 1 do
        array[i] = value
      end
      return array
    end,
    find_index = function(self, array, predicate, selfArg)
      return find_index(array, predicate, selfArg, 1, 1)
    end,
    find_last_index = function(self, array, predicate, selfArg)
      return find_index(array, predicate, selfArg, #array, -1)
    end,
    first = function(self, array)
      return array[1]
    end,
    head = function(self, ...)
      return self:first(...)
    end,
    flatten = function(self, array, isDeep)
      local t = { }
      self:each(array, function(item)
        if Utils:is_table(item) then
          local childeren
          if isDeep then
            childeren = self:flatten(item)
          else
            childeren = item
          end
          return self:each(childeren, function(value)
            return self:push(t, value)
          end)
        else
          return self:push(t, item)
        end
      end)
      return t
    end,
    flatten_deep = function(self, array)
      return self:flatten(array, true)
    end,
    fromPairs = function(self, array)
      local t = { }
      self:each(array, function(item)
        t[item[1]] = item[2]
      end)
      return t
    end,
    indexOf = function(self, array, value, fromIndex)
      return self:find_index(array, function(n)
        return n == value
      end)
    end,
    initial = function(self, array)
      return self:slice(array, nil, #array - 1)
    end,
    intersection = function(self, array, ...)
      local array_others = self:concat(...)
      return self:filter(array, function(item)
        return self:includes(array_others, item)
      end)
    end,
    intersection_by = function(self, array, ...)
      local tmp = Utils:to_table(...)
      local iteratee = self:pop(tmp)
      local subtracting = { }
      self:each(tmp, function(item)
        subtracting = self:concat(subtracting, item)
      end)
      local handler
      do
        local _base_1 = Utils
        local _fn_0 = _base_1.identity
        handler = function(...)
          return _fn_0(_base_1, ...)
        end
      end
      if Utils:is_string(iteratee) then
        handler = function(obj)
          return obj[iteratee]
        end
      end
      if Utils:is_function(iteratee) then
        handler = function(...)
          return iteratee(...)
        end
      end
      local minuend = self:map(array, function(item)
        return handler(item)
      end)
      subtracting = self:map(subtracting, function(item)
        return handler(item)
      end)
      return self:filter(array, function(_, index)
        return self:includes(subtracting, minuend[index])
      end)
    end,
    join = function(self, array, separator)
      return Utils:to_str(separator)(array)
    end,
    last_index_of = function(self, array, value, fromIndex)
      return self:find_last_index(array, function(n)
        return n == value
      end)
    end,
    nth = function(self, array, index)
      if index == nil then
        index = 1
      end
      local len = self:length(array)
      if (index > 0 and index <= self:length(array)) then
        return array[index]
      elseif (index < 0 and Math.abs(index) <= len) then
        len = len + 1
        return array[len + index]
      end
      return -1
    end,
    pull = function(self, array, ...)
      local i = 1
      while not Utils:is_nil(array[i]) do
        for _, v in ipairs(Utils:to_table(...)) do
          if array[i] == v then
            table.remove(array, i)
            return array
          end
        end
        i = i + 1
      end
      return array
    end,
    pull_all = function(self, array, array_others)
      local i = 1
      while not Utils:is_nil(array[i]) do
        for _, v in ipairs(array_others) do
          if array[i] == v then
            table.remove(array, i)
            return array
          end
        end
        i = i + 1
      end
      return array
    end,
    pull_at = function(self, array, ...)
      local t = { }
      local tmp = Utils:to_table(...)
      table.sort(tmp, function(a, b)
        return Utils:gt(a, b)
      end)
      self:each(tmp, function(item)
        return self:enqueue(t, table.remove(array, item))
      end)
      return t
    end,
    remove = function(self, array, predicate)
      local t = { }
      local c = 1
      predicate = predicate or (function()
        local _base_1 = Utils
        local _fn_0 = _base_1.identity
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)()
      while not Utils:is_nil(array[c]) do
        if predicate(array[c], c, array) then
          self:push(t, table.remove(array, c))
          return t
        end
        c = c + 1
      end
      return t
    end,
    rest = function(self, array)
      return self:slice(array, 2, #array)
    end,
    reverse = function(self, array)
      local t = { }
      for _, v in ipairs(array) do
        self:enqueue(t, v)
      end
      return t
    end,
    tail = function(self, array)
      self:shift(array)
      return array
    end,
    take = function(self, array, n)
      if n == nil then
        n = 1
      end
      return self:slice(array, 1, n)
    end,
    take_right = function(self, array, n)
      if n == nil then
        n = 1
      end
      return self:slice(array, #array - n + 1)
    end,
    take_rightwhile = function(self, array, predicate, selfArg)
      return take_while(array, predicate, selfArg, #array, -1, true)
    end,
    take_while = function(self, array, predicate, selfArg)
      return take_while(array, predicate, selfArg, 1, 1)
    end,
    union = function(self, ...)
      local tmp = Utils:to_table(...)
      local t = { }
      self:each(tmp(function()
        return function(array)
          return self:each(array, function(value)
            if self:indexOf(t, value) == -1 then
              return self:push(t, value)
            end
          end)
        end
      end))
      return t
    end,
    union_by = function(self, ...)
      return ...
    end,
    xor = function(self, array, ...)
      local array_other = self:concat_props(...)
      return self:concat(self:filter(array, function(item)
        return not self:includes(array_other, item)
      end), self:filter(array_other, function(item)
        return not self:includes(array, item)
      end))
    end,
    zip_all = function(self, ...)
      local t = { }
      for i, array in ipairs(Utils:to_table(...)) do
        for j, v in ipairs(array) do
          t[j] = t[j] or { }
          t[j][i] = v
        end
      end
      return t
    end,
    args = function(self, value)
      if Utils:is_table(value) then
        return table.unpack(value)
      else
        return table.unpack({
          value
        })
      end
    end,
    for_each = function(self, ...)
      return self:each(...)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Array"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  drop_while = function(array, predicate, selfArg, start, step, right)
    local t = { }
    local c = start
    while not Utils:is_nil(array[c]) do
      local cont
      cont = function()
        if #t == 0 and self:call_iteratee(predicate, selfArg, array[c], c, array) then
          c = c + step
          cont()
        end
        if right then
          Array:enqueue(t, array[c])
        else
          Array:push(t, array[c])
        end
        c = c + step
      end
      cont()
    end
    return t
  end
  find_index = function(array, predicate, selfArg, start, step)
    local c = start
    while not Utils:is_nil(array[c]) do
      if self:call_iteratee(predicate, selfArg, array[c], c, array) then
        return c
      end
      c = c + step
    end
    return -1
  end
  take_while = function(array, predicate, selfArg, start, step, right)
    local t = { }
    local c = start
    while not Utils:is_nil(array[c]) do
      if self:call_iteratee(predicate, selfArg, array[c], c, array) then
        if right then
          Array:enqueue(t, array[c])
        else
          Array:push(t, array[c])
        end
      else
        break
      end
      c = c + step
    end
    return t
  end
  Array = _class_0
end
local String
do
  local _class_0
  local _parent_0 = string
  local _base_0 = {
    each = function(self, str, callback)
      local index = 1
      return str:gsub(".", function(char)
        callback(char, index)
        index = index + 1
      end)
    end,
    map = function(self, str, callback)
      local new_str = ""
      local index = 1
      str:gsub(".", function(char)
        new_str = new_str + tostring(callback(char, index))
        index = index + 1
      end)
      return new_str
    end,
    map_array = function(self, str, callback)
      local array = { }
      local index = 1
      str:gsub(".", function(char)
        Array:push(array, callback(char, index))
        index = index + 1
      end)
      return array
    end,
    hash = function(self, str, str_search)
      return str:gmatch(tostring(str_search)) ~= nil
    end,
    hash_index = function(self, str, str_search)
      local _hash_index = -1
      if not self:hash(str, str_search) then
        return _hash_index
      end
      local index = 1
      local len = #str_search
      local _hash = false
      local index_true = 0
      str:gsub(".", function(char)
        if not _hash then
          if (char == self:nth(str_search, index_true + 1)) then
            index_true = index_true + 1
          else
            index_true = 0
          end
          if index_true == len then
            _hash = true
          end
          index = index + 1
        end
      end)
      local index_start = index - index_true
      local index_end = index - 1
      if _hash then
        return index_start, index_end
      else
        return -1
      end
    end,
    nth = function(self, str, index)
      return self.sub(str, index, index)
    end,
    substring = function(self, str, ...)
      return str:sub(...)
    end,
    length = function(self, str)
      return self.len(str)
    end,
    byte = function(self, str)
      return self.byte(str)
    end,
    byte_index = function(self, str, index)
      return str:byte(index)
    end,
    bytes = function(self, str)
      return self:map_array(str, self.byte)
    end,
    replace = function(self, str, search, replace)
      return self.gsub(str, search, replace)
    end,
    constant = function(self, value)
      return self:func(value)
    end,
    identity = function(self, ...)
      return ...
    end,
    iterRight = function(self, value)
      if Utils:is_string(value) then
        local i = #value + 1
        return function()
          if Utils:gt(i, 1) then
            i = i - 1
            local c = {
              value = sub(i, i)
            }
            return i, c
          end
        end
      elseif Utils:is_table(value) then
        return Collection:iter_collection(value, true)
      else
        return function() end
      end
    end,
    print = function(self, ...)
      local t = Utils:to_table(...)
      for i, v in ipairs(t) do
        t[i] = Utils:to_string(t[i])
      end
      return print(Utils:args(t))
    end,
    range = function(self, start, ...)
      start = start
      local args = Utils:to_table(...)
      local _ = a, b, c
      if #args == 0 then
        local a = 1
        local b = start
        local c = 1
      else
        local a = start
        local b = args[1]
        local c = args[2] or 1
      end
      local t = { }
      for i = a, b, c do
        Array:push(t, i)
      end
      return t
    end,
    keys = function(self, p)
      local t = { }
      for k in ipairs(p) do
        t[#t + 1] = k
      end
      return t
    end,
    is_empty = function(self, p)
      for k, v in pairs(p) do
        return false
      end
      return true
    end,
    sleep = function(self, seconds)
      local time = os.clock()
      while os.clock() - time <= seconds do
        local _ = nil
      end
    end,
    slow_write = function(self, text, rate)
      text = text and (tostring(text)) or ""
      rate = rate and 1 / (tonumber(rate)) or 1 / 20
      for n = 1, text:len() do
        self:sleep(rate)
        io.write(text:sub(n, n))
        io.flush()
      end
    end,
    slow_print = function(self, text, rate)
      self:slow_write(text, rate)
      return print()
    end,
    starts_with = function(self, text, start)
      return text:sub(1, start:len()) == start
    end,
    ends_with = function(self, text, ends)
      return (text:sub(-(ends:len()))) == ends
    end,
    first_upper = function(self, text)
      if text then
        return text:gsub("^%l", string.upper)
      end
    end,
    first_word_upper = function(self, text)
      if text then
        return text:gsub("%a", string.upper, 1)
      end
    end,
    first_lower = function(self, text)
      if text then
        return text:gsub("^%u", string.lower)
      end
    end,
    first_word_lower = function(self, text)
      if text then
        return text:gsub("%a", string.lower, 1)
      end
    end,
    title_case = function(self, text)
      return text:gsub("(%a)([%w_']*)", function(first, rest)
        if text then
          return first:upper() .. rest:lower()
        end
      end)
    end,
    all_lower = function(self, text)
      if text then
        return text:gsub("%f[%a]%u+%f[%A]", string.lower)
      end
    end,
    all_upper = function(self, text)
      if text then
        return text:gsub("%f[%a]%l+%f[%A]", string.upper)
      end
    end,
    url_encode = function(self, text)
      if text then
        text = text:gsub("\n", "\r\n")
        text = text:gsub("([^%w %-%_%.%~])", function(c)
          return ("%%%02X"):format(string.byte(c))
        end)
        text = text:gsub(" ", "+")
      end
    end,
    url_decode = function(self, text)
      if text then
        text = text:gsub("+", " ")
        text = text:gsub("%%(%x%x)", function(h)
          return string.char(tonumber(h, 16))
        end)
        text = text:gsub("\r\n", "\n")
      end
    end,
    trimr = function(self, text)
      if text then
        return text:match("(.-)%s*$")
      end
    end,
    triml = function(self, text)
      if text then
        return text:match("^%s*(.*)")
      end
    end,
    trim = function(self, text)
      if text then
        return trimr(triml(text))
      end
    end,
    split = function(self, text, sep, max, plain)
      if sep == nil then
        sep = " "
      end
      if sep == "" then
        sep = " "
      end
      local parts = { }
      if text:len() > 0 then
        max = max or -1
        local nf, ns = 1, 1
        local nl
        nf, nl = text:find(sep, ns, plain)
        while nf and (max ~= 0) do
          parts[nf] = text:sub(ns, nf - 1)
          nf = nf + 1
          ns = nl + 1
          nf, nl = text:find(sep, ns, plain)
          local nm = nm - 1
        end
        parts[nf] = text:sub(ns)
      end
      return parts
    end,
    _arrow = function(self, text, full)
      if full == nil then
        full = true
      end
      return "=> " .. tostring((function()
        if not full then
          return "%{reset}"
        else
          return ""
        end
      end)()) .. tostring(text)
    end,
    _dart = function(self, text, full)
      if full == nil then
        full = true
      end
      return "-> " .. tostring((function()
        if not full then
          return "%{reset}"
        else
          return ""
        end
      end)()) .. tostring(text)
    end,
    _pin = function(self, text, full)
      if full == nil then
        full = true
      end
      return "-- " .. tostring((function()
        if not full then
          return "%{reset}"
        else
          return ""
        end
      end)()) .. tostring(text)
    end,
    _bullet = function(self, text, full)
      if full == nil then
        full = true
      end
      return " * " .. tostring((function()
        if not full then
          return "%{reset}"
        else
          return ""
        end
      end)()) .. tostring(text)
    end,
    _quote = function(self, text, full)
      if full == nil then
        full = true
      end
      return " > " .. tostring((function()
        if not full then
          return "%{reset}"
        else
          return ""
        end
      end)()) .. tostring(text)
    end,
    _title = function(self, text, full)
      if full == nil then
        full = true
      end
      return "== " .. tostring((function()
        if not full then
          return "%{reset}"
        else
          return ""
        end
      end)()) .. tostring(text)
    end,
    _error = function(self, text, full)
      if full == nil then
        full = true
      end
      return "!! " .. tostring((function()
        if not full then
          return "%{reset}"
        else
          return ""
        end
      end)()) .. tostring(text)
    end,
    printf = function(self, text, ...)
      return print(string.format(text, ...))
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "String",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  String = _class_0
end
local Collection
do
  local _class_0
  local filter, handler_iteratee
  local _base_0 = {
    get_sorted_keys = function(collection, desc)
      local sortedKeys = { }
      for k, v in pairs(collection) do
        table.insert(sortedKeys, k)
      end
      if desc then
        table.sort(sortedKeys, (function()
          local _base_1 = lodash_
          local _fn_0 = _base_1.gt
          return function(...)
            return _fn_0(_base_1, ...)
          end
        end)())
      else
        table.sort(sortedKeys, (function()
          local _base_1 = lodash_
          local _fn_0 = _base_1.lt
          return function(...)
            return _fn_0(_base_1, ...)
          end
        end)())
      end
      return sortedKeys
    end,
    iter_collection = function(self, table, desc)
      local sortedKeys = get_sorted_keys(table, desc)
      local i = 0
      return function()
        if lodash_:lt(i, #sortedKeys) then
          i = i + 1
          local key = sortedKeys[i]
          return key, table[key]
        end
      end
    end,
    nth = function(self, object, key)
      return object[key]
    end,
    nth = function(self, object, key)
      return object[key]
    end,
    hash_key = function(self, object, key)
      local value = false
      if self:nth(object, key) then
        value = true
      else
        self:each(object, function(_, key_loca)
          if Utils:to_string(key) == Utils:to_string(key_loca) then
            value = true
          end
        end)
        return value
      end
    end,
    for_each = function(self, ...)
      return self:each(...)
    end,
    each = function(self, ...)
      return self:map(...) and true
    end,
    map = function(self, object, callback)
      local _accum_0 = { }
      local _len_0 = 1
      for key, item in pairs(object) do
        _accum_0[_len_0] = callback(item, key)
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end,
    map_reverse = function(self, obj, callback)
      local _accum_0 = { }
      local _len_0 = 1
      for i = #obj, 1, -1 do
        _accum_0[_len_0] = callback(obj[i], i)
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end,
    for_each_right = function(self, ...)
      return self:map_reverse(...) and true
    end,
    each_right = function(self, ...)
      return self:map_reverse(...) and true
    end,
    count_by = function(self, array, iteratee)
      local object = { }
      local handler = handler_iteratee(iteratee)
      Array:each(array, function(item)
        local value = handler(item)
        if (self:hash_key(object, value)) then
          object[Utils:to_string(value)] = object[Utils:to_string(value)] + 1
        else
          object[Utils:to_string(value)] = 1
        end
      end)
      return object
    end,
    hash_item = function(self, object, key, value)
      if self:hash_key(object, key) then
        if object[key] == value then
          return true
        end
      end
      return false
    end,
    hash_value = function(self, object, value)
      local hash_value_ = false
      self:each(object, function(item)
        if item == value then
          hash_value_ = true
        end
      end)
      return hash_value_
    end,
    every = function(self, array, predicate, callback)
      if callback == nil then
        do
          local _base_1 = Utils
          local _fn_0 = _base_1.identity
          callback = function(...)
            return _fn_0(_base_1, ...)
          end
        end
      end
      local _every = false
      local key = predicate[1]
      local value = predicate[2]
      Array:each(array, function(object)
        if self:hash_item(object, key, value) then
          _every = true
          return callback(object, key, value)
        end
      end)
      return _every
    end,
    find_all = function(self, array, predicate)
      return Array:map(array, function(object)
        if predicate(object) then
          return object
        end
      end)
    end,
    find_last = function(self, array, predicate)
      local o = nil
      Array:map(array, function(object)
        if predicate(object) then
          o = object
        end
      end)
      return o
    end,
    find = function(self, array, predicate)
      local o = nil
      Array:map_reverse(array, function(object)
        if predicate(object) then
          o = object
        end
      end)
      return o
    end,
    group_by = function(self, array, iteratee)
      local object = { }
      local handler = handler_iteratee(iteratee)
      Array:each(array, function(item)
        local value = handler(item)
        if (self:hash_key(object, value)) then
          object[Utils:to_string(value)] = Array:push_new(object[Utils:to_string(value)], item)
        else
          object[Utils:to_string(value)] = {
            item
          }
        end
      end)
      return object
    end,
    includes = function(self, object, value, fromIndex)
      if fromIndex == nil then
        fromIndex = false
      end
      local _includes = false
      if Utils:is_string(object) then
        if fromIndex then
          local index = String:hash_index(object, value)
          return index == fromIndex
        else
          return String:hash(object, value)
        end
      end
      try(function()
        if fromIndex then
          _includes = self:hash_item(object, fromIndex, value)
        else
          _includes = self:hash_value(object, value)
        end
        if _includes == nil then
          return error()
        end
      end).catch(function(err)
        return Array:map(object, function(item, index)
          if fromIndex and value == item and index == fromIndex then
            _includes = true
          elseif value == item then
            _includes = true
          end
        end)
      end)
      return _includes
    end,
    invoke_map = function(self, array, iteratee, arg1, arg2)
      iteratee = iteratee or (function()
        local _base_1 = Utils
        local _fn_0 = _base_1.identity
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)()
      return Array:map(array, function(item)
        return iteratee(item, arg1, arg2)
      end)
    end,
    key_by = function(self, array, iteratee)
      if iteratee == nil then
        do
          local _base_1 = Utils
          local _fn_0 = _base_1.identity
          iteratee = function(...)
            return _fn_0(_base_1, ...)
          end
        end
      end
      local tmp = Utils:to_table()
      Array:each(array, function(item)
        local key = iteratee(item)
        if key then
          if tmp[tostring(key)] then
            local object
            array, object = Utils:array_or_object(tmp[tostring(key)])
            if array then
              tmp[tostring(key)] = Array:concat(tmp[tostring(key)], {
                item
              })
            elseif object then
              tmp[tostring(key)] = Array:concat({
                tmp[tostring(key)]
              }, {
                item
              })
            end
          else
            tmp[tostring(key)] = item
          end
        end
      end)
      return tmp
    end,
    iter = function(self, value)
      if Utils:is_string(value) then
        local i = 0
        return function()
          if Utils:lt(i, #value) then
            i = i + 1
            local c = {
              value = sub(i, i)
            }
            return i, c
          end
        end
      else
        return Collection:iter_collection(value)
      end
    end,
    some = function(self, collection, predicate, selfArg)
      for k, v in self:iter(collection) do
        if Array:call_iteratee(predicate, selfArg, v, k, collection) then
          return true
        end
      end
      return false
    end,
    reject = function(self, collection, predicate, selfArg)
      return filter(collection, predicate, selfArg, true)
    end,
    sample = function(self, collection, n)
      n = n or 1
      local t = { }
      local keys = self:keys(collection)
      for i = 1, n do
        local pick = keys[Number:random(1, #keys)]
        Array:push(t, self:get(collection, {
          pick
        }))
      end
      return #t == 1 and t[1] or t
    end,
    size = function(self, collection)
      local c = 0
      for k, v in self:iter(collection) do
        c = c + 1
      end
      return c
    end,
    sort = function(self, p, f)
      f = f or function(a, b)
        return a < b
      end
      local t = Collection:value(p)
      table.sort(t, f)
      return t
    end,
    value = function(self, p)
      local t = { }
      for v in Utils:iter(p) do
        t[#t + 1] = v
      end
      return t
    end,
    sort_by = function(self, collection, predicate, selfArg)
      local t = { }
      local empty = true
      local _ = previous
      for k, v in self:iter(collection) do
        if empty then
          Array:push(t, v)
          local previous = call_iteratee(predicate, selfArg, v, k, collection)
          empty = false
        else
          local r = call_iteratee(predicate, selfArg, v, k, collection)
          if Utils:lt(previous, r) then
            table.insert(t, v)
            local previous = r
          else
            table.insert(t, #t, v)
          end
        end
      end
      return t
    end,
    keys = function(self, object)
      if Utils:is_table(object) then
        return self:get_sorted_keys(object)
      elseif Utils:is_string(object) then
        local keys = { }
        for i = 1, #object do
          keys[i] = i
        end
        return keys
      end
    end,
    get = function(self, object, path, defaultValue)
      if Utils:is_table(object) then
        local value = object
        local c = 1
        while not Utils:is_nil(path[c]) do
          if not Utils:is_table(value) then
            return defaultValue
          end
          value = value[path[c]]
          c = c + 1
        end
        return value or defaultValue
      elseif Utils:is_string(object) then
        local index = path[1]
        return {
          object = sub(index, index)
        }
      end
    end,
    has = function(self, object, path)
      local obj = object
      local c = 1
      local exist = true
      while not Utils:is_nil(path[c]) do
        obj = obj[path[c]]
        if Utils:is_nil(obj) then
          exist = false
          break
        end
        c = c + 1
      end
      return exist
    end,
    values = function(self, p)
      local t = { }
      for k, v in pairs(p) do
        t[#t + 1] = v
      end
      return t
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Collection"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  filter = function(collection, predicate, selfArg, reject)
    local t = { }
    for k, v in lodash_:iter(collection) do
      local check = Array:call_iteratee(predicate, selfArg, v, k, collection)
      if reject then
        if not check then
          lodash_:push(t, v)
        end
      else
        if check then
          lodash_:push(t, v)
        end
      end
    end
    return t
  end
  handler_iteratee = function(iteratee)
    local handler
    do
      local _base_1 = Utils
      local _fn_0 = _base_1.identity
      handler = function(...)
        return _fn_0(_base_1, ...)
      end
    end
    if Utils:is_string(iteratee) then
      handler = function(obj)
        return obj[iteratee]
      end
    end
    if Utils:is_function(iteratee) then
      handler = function(...)
        return iteratee(...)
      end
    end
    return handler
  end
  Collection = _class_0
end
local Knockout = (function()
  local recorders = { }
  local mt = {
    __tostring = function(self)
      return "Property " .. self.name .. ": " .. tostring(self.__value)
    end,
    __call = function(self, nv)
      if nv ~= nil and nv ~= self.__value then
        self.__value = nv
        for p in pairs(self.__tos) do
          p(nv)
        end
      else
        if nv == nil then
          for r in pairs(recorders) do
            r(self)
          end
        end
      end
      return self.__value
    end,
    __index = {
      push_to = function(self, pushee)
        self.__tos[pushee] = pushee
        return function()
          self.__tos[pushee] = nil
        end
      end,
      peek = function(self)
        return self.__value
      end,
      writeproxy = function(self, proxy)
        return setmetatable({ }, {
          __tostring = function(t)
            return "(proxied) " .. tostring(self)
          end,
          __index = self,
          __call = function(t, nv)
            if nv ~= nil then
              return self(proxy(nv))
            else
              return self()
            end
          end
        })
      end
    }
  }
  local property
  property = function(v, name)
    if name == nil then
      name = "<unnamed>"
    end
    return setmetatable({
      __value = v,
      __tos = { },
      name = name
    }, mt)
  end
  local record_pulls
  record_pulls = function(f)
    local sources = { }
    local rec
    rec = function(p)
      sources[p] = p
    end
    recorders[rec] = rec
    local status, res = pcall(f)
    recorders[rec] = nil
    if not status then
      return false, res
    else
      return sources, res
    end
  end
  local readonly
  readonly = function(self)
    return self:writeproxy(function(nv)
      return error("attempted to set readonly property '" .. tostring(self) .. "' with value " .. tostring(nv))
    end)
  end
  local computed
  computed = function(reader, writer, name)
    if name == nil then
      name = "<unnamed>"
    end
    local p = property(nil, name)
    p.__froms = { }
    local update
    update = function()
      if not p.__updating then
        p.__updating = true
        local newfroms, res = record_pulls(reader)
        if not newfroms then
          p.__updating = false
          error(res)
        end
        for f, remover in pairs(p.__froms) do
          if not newfroms[f] then
            p.__froms[f] = nil
            remover()
          end
        end
        for f in pairs(newfroms) do
          if not p.__froms[f] then
            p.__froms[f] = f:push_to(update)
          end
        end
        p(res)
        p.__updating = false
      end
    end
    update()
    if not writer then
      return readonly(p)
    else
      return p:writeproxy(function(nv)
        if not p.__updating then
          p.__updating = true
          local status, res = pcall(writer, nv)
          p.__updating = false
          if status then
            return res
          else
            return error(res)
          end
        end
      end)
    end
  end
  return {
    property = property,
    readonly = readonly,
    computed = computed,
    record_pulls = record_pulls
  }
end)()
local Promise = (function()
  local _Promise, promise = { }, { }
  local PENDING = { }
  local nil_promise = { }
  local promised
  promised = function(value, action)
    local ok, result = pcall(action, value)
    return ok and _Promise.resolve(result) or _Promise.reject(result)
  end
  local promised_s
  promised_s = function(self, onFulfilled)
    return onFulfilled and promised(self, onFulfilled) or self
  end
  local promised_y
  promised_y = function(self, onFulfilled)
    return onFulfilled and promised(self[1], onFulfilled) or self
  end
  local promised_n
  promised_n = function(self, _, onRejected)
    return onRejected and promised(self[1], onRejected) or self
  end
  local inext
  inext = function(a, i)
    i = i + 1
    local v = a[i]
    if v then
      return i, v
    end
  end
  local resolver
  resolver = function(this, resolved, sure)
    local typ = type(resolved)
    if (typ == 'table' and resolved.andThen) then
      local lazy = {
        this,
        function(value)
          return resolver(this, value, true), function(reason)
            return resolver(this, reason, false)
          end
        end
      }
      if resolved[1] == PENDING then
        return table.insert(resolved, lazy)
      else
        return {
          resolved = andThen(lazy[2], lazy[3])
        }
      end
    else
      if this[1] == PENDING then
        this[1], this.andThen = resolved, sure and promised_y or promised_n
      end
      for i, lazy, action in inext,this,1 do
        action = (sure and lazy[2]) or (not sure and lazy[3])
        pcall(resolver, lazy[1], action and promised(resolved, action) or (sure and _Promise.resolve or _Promise.reject)(resolved), sure)
        this[i] = nil
      end
    end
  end
  local coroutine_push
  coroutine_push = function(co, promises)
    coroutine.resume(co)
    local resume_y
    resume_y = function(value)
      return coroutine.resume(co, true, value)
    end
    local resume_n
    resume_n = function(reason)
      return coroutine.resume(co, false, reason)
    end
    for i = 1, #promises do
      if promises[i][1] == PENDING then
        promises[i]:andThen(resume_y, resume_n)
      end
    end
  end
  promise.__index = promise
  local number_promise = setmetatable({
    andThen = promised_y
  }, promise)
  local true_promise = setmetatable({
    andThen = promised_y,
    true
  }, promise)
  local false_promise = setmetatable({
    andThen = promised_y,
    false
  }, promise)
  number_promise.__index = number_promise
  nil_promise.andThen = promised_y
  getmetatable('').__index.andThen = promised_s
  getmetatable('').__index.catch = function(self)
    return self
  end
  setmetatable(nil_promise, promise)
  local _ = {
    promise = andThen(onFulfilled, onRejected)(function()
      local lazy = {
        {
          PENDING
        },
        onFulfilled,
        onRejected
      }
      table.insert(self, lazy)
      return setmetatable(lazy[1], promise)
    end)
  }
  _ = {
    promise = catch(onRejected)(function()
      return {
        self = andThen(nil, onRejected)
      }
    end)
  }
  _Promise.resolve(value)(function()
    local valueType = type(value)
    if valueType == 'nil' then
      return nil_promise
    elseif valueType == 'boolean' then
      return value and true_promise or false_promise
    elseif valueType == 'number' then
      return setmetatable({
        (value)
      }, number_promise)
    elseif valueType == 'string' then
      return value
    elseif (valueType == 'table') and (value.andThen ~= nil) then
      return value.catch ~= nil and value or setmetatable({
        catch = promise.catch
      }, {
        __index = value
      })
    else
      return setmetatable({
        andThen = promised_y,
        value
      }, promise)
    end
  end)
  _Promise.reject(reason)(function()
    return setmetatable({
      andThen = promised_n,
      reason
    }, promise)
  end)
  _Promise.all(arr)(function()
    local this, promises, count = setmetatable({
      PENDING
    }, promise), { }, #arr
    local co = coroutine.create(function()
      local i, result, sure, last = 1, { }, true, 0
      while i <= count do
        local typ, reason, resolved
        promise, typ, reason, resolved = promises[i], type(promises[i])
        if typ == 'table' and promise.andThen and promise[1] == PENDING then
          sure, reason = coroutine.yield()
          if not sure then
            return resolver(this, {
              index = i,
              reason = reason
            }, sure)
          end
        else
          sure = (typ == 'string') or (typ == 'table' and promise.andThen ~= promised_n)
          resolved = (typ == 'string') and promise or promise[1]
          if not sure then
            return resolver(this, {
              index = i,
              reason = resolved
            }, sure)
          end
          result[i] = resolved
          if result[i] ~= nil then
            last = i
          end
          i = i + 1
        end
      end
      return resolver(this, sure and {
        unpack(result, 1, last)
      } or result, sure)
    end)
    for i, item in ipairs(arr) do
      promises[i] = _Promise.resolve(item)
    end
    coroutine_push(co, promises)
    return this
  end)
  _Promise.race(arr)(function()
    local this, result, count = setmetatable({
      PENDING
    }, promise), { }, #arr
    local co = coroutine.create(function()
      local i, sure, resolved = 1
      while i < count do
        local typ
        promise, typ = result[i], type(result[i])
        if typ == 'table' and promise.andThen and promise[1] == PENDING then
          sure, resolved = coroutine.yield()
        else
          sure = (typ == 'string') or (typ == 'table' and promise.andThen ~= promised_n)
          resolved = typ == 'string' and promise or promise[1]
        end
        break
      end
      return resolver(this, resolved, sure)
    end)
    for i, item in ipairs(arr) do
      promises[i] = _Promise.resolve(item)
    end
    coroutine_push(co, promises)
    return this
  end)
  _Promise.new(func)(function()
    local this = setmetatable({
      PENDING
    }, promise)
    local ok, result = pcall(func, function(value)
      return resolver(this, value, true), function(reason)
        return resolver(this, reason, false)
      end
    end)
    return ok and this or _Promise.reject(result)
  end)
  return _Promise
end)()
