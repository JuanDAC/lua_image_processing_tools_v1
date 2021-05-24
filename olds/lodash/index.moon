try = (try_block) ->
	status = true
	err = nil
	if  Utils\is_function(try_block)
		status, err = xpcall(try_block, debug.traceback)
	finally = (finally_block, catch_block_declared) ->
		if Utils\is_function(finally_block)
			finally_block()
		if not catch_block_declared and not status
			error(err)
	catch = (catch_block) ->
		catch_block_declared = Utils\is_function(catch_block)
		if not status and catch_block_declared
			ex = err or "unknown error occurred"
			catch_block(ex)
		return {
			finally: (finally_block) -> finally(finally_block, catch_block_declared)
		}
	return {
		catch: catch,
		finally: (finally_block) -> finally(finally_block, false)
	}
--


class Utils 
	dbl_quote = (v) ->
		return '"'..v..'"'
	gt: (value, other, ...) =>
		value, other = @cast(value, other)
		if @is_string(value) or @is_number(value)  
			return value > other
		elseif @is_function(value) 
			return value(...) > other(...)
		return false
	cast: (a, b) =>
		if type(a) == type(b)  return a, b 
		cast
		if @is_string(a)
			cast = @str
		elseif @is_boolean(a)
			cast = @bool
		elseif @is_number(a)
			cast = @num
		elseif @is_function(a)
			cast = @func
		elseif @is_table(a)
			cast = Utils\to_table
		return a, cast(b)
	gte: (value, other, ...) =>    
		if @is_nil(value) or @is_boolean(value)  
			return value == other
		value, other = @cast(value, other)
		if @is_string(value) or @is_number(value)  
			return value >= other
		elseif @is_function(value) 
			return value(...) >= other(...)
		elseif @is_table(value)
			return false
		return false
	is_boolean: (value) =>
		return type(value) == 'boolean'
	is_empty: (value) =>
		if @is_string(value) 
			return #value == 0
		elseif @is_table(value) 
			i = 0
			for k, v in Collection\iter(value)
				i = i + 1
			return i == 0
		else
			return true
	is_function: (value) =>
		return type(value) == 'function'
	is_nil: (value) =>
		return type(value) == 'nil'
	is_number: (value) =>
		return type(value) == 'number'
	is_string: (value) =>
		return type(value) == 'string'
	is_table: (value) =>
		return type(value) == 'table'
	args: (value) => if @is_table(value) then table.unpack(value) else table.unpack({value})
	lt: (value, other, ...) =>
		value, other = @cast(value, other)
		if @is_string(value) or @is_number(value)  
			return value < other
		elseif @is_function(value) 
			return value(...) < other(...)
		return false
	lte: (value, other, ...) =>    
		if @is_nil(value) or @is_boolean(value)  
			return value == other
		value, other = @cast(value, other)
		if @is_string(value) or @is_number(value)  
			return value <= other
		elseif @is_function(value) 
			return value(...) <= other(...)
		elseif @is_table(value) 
			return false
		return false
	to_func: (...) =>
		t = @to_table(...)
		return () ->
			return @args(t)
	to_table: (...) => table.pack(...)
	to_bool: (value, ...) =>
		bool = false
		if @is_string(value)      
			bool = #value > 0
		elseif @is_boolean(value) 
			bool = value
		elseif @is_number(value) 
			bool = value ~= 0
		elseif @is_function(value) 
			bool = @to_bool(value(...))
		return bool
	to_num: (value, ...) =>
		num = 0
		if @is_string(value)    
			ok = pcall(() -> num = value + 0)
			if not ok 
				num = math.huge
		elseif @is_boolean(value) 
			num = value and 1 or 0
		elseif @is_number(value) 
			num = value
		elseif @is_function(value) 
			num = @num(value(...))
		return num
	to_str: (separator = ', ') => (value, ...)  -> 
		str = ''
		if @is_string(value)
			str = value
		elseif @is_boolean(value) 
			str = value and 'true' or 'false'
		elseif @is_nil(value)
			str = 'nil'
		elseif @is_number(value) 
			str = value .. ''
		elseif @is_function(value)
			str = @to_str(separator)(value(...))
		elseif @is_table(value)
			str = '{'
			for k, v in pairs(value)
				v = if @is_string(v) then dbl_quote(v) else @to_str(separator)(v, ...)
				if @is_number(k) 
					str = "#{str}#{v}#{separator}"
				else
					str = "#{str}[#{dbl_quote(k)}]=#{v}#{separator}"
			str = "#{str\sub(0, #str - #separator)}}"
		return str
	to_string: (...) => @to_str(', ')(...)
	array_or_object: (obj) => 
		array = false
		object = false
		tyr(() ->
			pairs(obj)
			object = true
		).catch(() -> 
			array = true
		)
		return array, object
	noop: (...) => nil 
	identity: (...) => ...
	iter: (p) =>
		if type(p) == 'function' 
			return p
		return coroutine.wrap(() -> coroutine.yield(p[i]) for i = 1, #p)
	range: (s, l, step) =>
		step = step or 1
		if not l 
			l = s
			s = 1
			step = 1
		t = {}
		for i = s, l, step
			t[#t + 1] = i
		return t
	is_equal: (a, b) =>
		if a == b
			return true
		elseif type(a) != type(b)
			return false
		elseif type(a) != 'table' 
			return false
		t = {}
		for k, v in pairs(b)
			t[k] = v
		for k, v in pairs(a)
			if not mu.is_equal(v, t[k]) 
				return false
			t[k] = nil
		for k, v in pairs(t)
			return false
		return true





	



--



class Function 
	type: "function"
	is_callable: (fn) => type(fn) == @type
	is_function: (...) => Utils\is_callable(...)
	after: (n, func) =>
		i = 1
		return (...) ->
			if Utils\gt(i, n) 
				return func(...)
			i = i + 1
	ary: (func, n) =>
		return (...) ->
			if n == 1 
				return func((...))
			else
				t = Utils\to_table(...)
				first = Array\take(t, n)
				return func(@args(first))
	before: (n, func) =>
		i = 1
		result
		return (...) ->
			if Utils\lte(i, n) 
				result = func(...)  
			i = i + 1
			return result
	modArgs: (func, ...) =>
		transforms = {}
		for i, v in ipairs( Utils\to_table(...))
			if Utils\is_function(v)
				Array\push(transforms, v) 
			elseif Utils\is_table(v)
				for k2, v2 in Collection\iter(v)
					if Utils\is_function(v2) 
						Array\push(transforms, v2)
		return (...) ->
			args
			for i, transform in ipairs(transforms)
				if Utils\is_nil(args) 
					args = Utils\to_table(transform(...))
				else
					args = Utils\to_table(transform(@args(args)))
			if Utils\is_nil(args) 
				return func(...)
			else
				return func(@args(args))
	negate: (func) =>
		return (...) ->
			return not func(...)
	once: (func) =>
		called = false
		result
		return (...) ->
			if not called 
				result = func(...)
				called = true
			return result
	rearg: (func, ...) =>
		indexes = {}
		for i, v in ipairs(Utils\to_table(...))
			if Utils\is_number(v)  
				Array\push(indexes, v) 
			elseif Utils\is_table(v) 
				for k2, v2 in Collection\iter(v)
					if Utils\is_number(v2)
						Array\push(indexes, v2)
		
		return (...) ->
			args = Utils\to_table(...)
			newArgs = {}
			for i, index in ipairs(indexes)  
				Array\push(newArgs, args[index]) 
			if #indexes == 0 
				return func(...)
			else
				return func(@args(newArgs))
	args: (value) =>
		if Utils\is_table(value)
			table.unpack(value) 
		else 
			table.unpack({value})
	curry: (f) => 
		info = debug.getinfo(f, 'u')
		docurry = (s, left, ...) ->
			ptbl = Array\clone(s)
			vargs = {...}
			for i = 1, #vargs
				ptbl[#ptbl + 1] = vargs[i]
			left = left - #vargs
			if left > 0
				return (...) -> docurry(ptbl, left, ...)
			else
				return f(unpack(ptbl))
		return (...) -> docurry({}, info.nparams, ...)
	curry_closure: (f, n, ...) =>
		args = {...}
		cu = (...) ->
			for i, v in ipairs{...}
				args[#args + 1] = v
			if #args >= n
				return f(table.unpack(args))
			return cu
		return cu
	wrap: (f, wr) =>
		return (...) -> wr(f, ...)
	compose: (...) =>
		fs = {...}
		return (...) ->
			args = {...}
			for i = #fs, 1, -1
				args = {fs[i](table.unpack(args))}
			return table.unpack(args)

--



class Math extends math
--



class Number 
	type: "number"
	private_NaN = 0/0
	private_INF = 1/0
	new: (value) => if (value) then @value = tonumber(value)
	get_value: () => @value
	is_NaN: (value) => value == private_NaN
	is_INF: (value) => value == private_INF
	is_number: (value) => type(Number(value)) == @type
	to_integer: (value) => 
		number = tonumber(value)
		if (Utils\is_NaN(number))
			return 0
		if (number == 0 or Utils\is_INF(number)) 
			return number
		return (if number > 0 then 1 else -1) * Math.floor(Math.abs(number))
	in_range: (n, start, stop) =>
		_start = Utils\is_nil(stop) and 0 or start or 0
		_stop = Utils\is_nil(stop) and start or stop or 1
		return n >= _start and n < _stop
	random: (min, max, floating) =>
		minim = Utils\is_nil(max) and 0 or min or 0
		maxim = Utils\is_nil(max) and min or max or 1
		Math.randomseed(os.clock() * Math.random(os.time()))
		r = Math.random(minim, maxim)
		if floating 
			r = r + Math.random()
		return r

--



class Array
	extend: (d, s) =>
		for k, v in pairs(s)
			d[k] = v
		return d
	clone: (array) =>
		r = {}
		for i = 1, #array
			r[#r + 1] = array[i]
		return r
	call_iteratee: (predicate, selfArg, ...) =>
		result
		predicate = predicate or Utils\identity
		if selfArg 
			result = predicate(selfArg, ...)
		else
			result = predicate(...)
		return result
	drop_while = (array, predicate, selfArg, start, step, right) ->
		t = {}
		c = start
		while not Utils\is_nil(array[c])
			cont = () -> 
				if #t == 0 and @call_iteratee(predicate, selfArg, array[c], c, array) 
					c = c + step
					cont!
				if right 
					Array\enqueue(t, array[c])
				else
					Array\push(t, array[c])
				c = c + step
			cont!
		return t
	find_index = (array, predicate, selfArg, start, step) ->
		c = start
		while not Utils\is_nil(array[c])
			if @call_iteratee(predicate, selfArg, array[c], c, array) 
				return c
			c = c + step
		return -1
	take_while = (array, predicate, selfArg, start, step, right) ->
		t = {}
		c = start
		while not Utils\is_nil(array[c])
			if @call_iteratee(predicate, selfArg, array[c], c, array) 
				if right 
					Array\enqueue(t, array[c])
				else
					Array\push(t, array[c])
			else
				break
			c = c + step
		return t
	is_table: (obj) =>
		return type(obj) == 'table'
	lowest_value: (a, b) =>
		return a < b and a or b
	multiple_inserts: (obj, values) =>
		for i=1, #values 
			value = values[i]
			table.insert(obj, value)
	convert_to_hash: (obj) =>
		output = {}
		for i=1, #obj 
			value = obj[i]
			output[value] = true
		return output
	is_array: (obj) =>
		if not Utils\is_table(obj)
			return false
		i = 0
		for _ in pairs(obj)
			i += 1
			if obj[i] == nil
				return false
		return true
	is_empty: (obj) =>
		return #obj == 0
	slice: (obj, start, finish) =>
		if Utils\is_empty(obj)
			return {}
		_start = start or 1
		output = {}
		for i=_start, finish or #obj
			@push(output, obj[i])
		return output
	length: (array) => #array
	len: (...) => @length(...)
	index_of: (obj, value) =>
		for i=1, #obj
			if obj[i] == value
				return i
		return -1
	includes: (obj, value) =>
		index = @index_of(obj, value)
		if index == -1 
			return false
		return true
	reverse: (obj) =>
		output = {}
		for i=#obj, 1, -1
			table.insert(output, obj[i])
		return output
	last: (obj) =>
		return obj[#obj]
	max: (obj) =>
		max = obj[1]
		for i=2, #obj
			if obj[i] > max
				max = obj[i]
		return max
	min: (obj) =>
		min = obj[1]
		for i=2, #obj 
			if obj[i] < min 
				min = obj[i]
		return min
	map: (array, callback) => [callback(array[i], i) for i=1, #array]
	map_reverse: (array, callback) => [callback(array[i], i) for i = #array, 1, -1 ]
	filter: (array, callback) => [item for i=1, #array when callback(item, i)]
	reduce: (obj, callback, memo) =>
		initialIndex = 1
		_memo = memo
		if _memo == nil 
			initialIndex = 2
			_memo = obj[1]
		for i=initialIndex, #obj 
			_memo = callback(_memo, obj[i], i)
		return _memo
	reduce_right: (obj, callback, memo) =>
		initialIndex = #obj
		_memo = memo
		if _memo == nil 
			initialIndex = initialIndex - 1
			_memo = obj[#obj]
		for i=initialIndex, 1, -1 
			_memo = callback(_memo, obj[i], i)
		return _memo
	sum: (obj) => @reduce(obj, (memo, value) -> memo + value)
	concat: (array, ...) =>
		output = {}
		@each(array, (item) ->
			@push(output, item)
		)
		array_others = Utils\to_table(...)
		if @length(array_others) > 0
			@each(array_others, (array_current) ->
				@each(array_current, (item) ->
					@push(output, item)
				)
			)
		return output
	uniq: (obj) =>
		output = {}
		seen = {}
		for i=1, #obj
			value = obj[i]
			if not seen[value] 
				seen[value] = true
				table.insert(output, value)
		return output
	without: (obj, values) => 
		initial_value = {}
		reducer = (accumulator, current) =>
			if (@includes(values, current) == false) 
				table.insert(accumulator, current)
			return accumulator
		return @reduce(obj, reducer, initial_value)
	some: (obj, callback) =>
		for i=1, #obj 
			if callback(obj[i], i)
				return true
		return false
	zip: (obj1, obj2) =>
		output = {}
		size = #obj1 > #obj2 and #obj2 or #obj1
		for i=1, size 
			table.insert(output, { obj1[i], obj2[i] })
		return output
	every: (obj, callback) =>
		for i=1, #obj 
			if not callback(obj[i], i) 
				return false
		return true
	shallow_copy: (obj) =>
		output = {}
		for i=1, #obj 
			table.insert(output, obj[i])
		return output
	deep_copy: (value) =>
		output = value
		if Utils\is_table(value) 
			output = {}
			for i=1, #value 
				table.insert(output, @deep_copy(value[i]))
		return output
	diff: (obj1, obj2) =>
		output = {}
		hash = @convert_to_hash(obj2)
		for i=1, #obj1 
			value = obj1[i]
			if not hash[value] 
				table.insert(output, value)
		return output
	flat: (obj) =>
		cb = (acc, item) ->
			if Utils\is_array(item)
				return @concat(acc, @flat(item))
			else
				table.insert(acc, item)
				return acc
		return @reduce(obj, cb, {})
	fill: (value, start_or_finish, finish) =>
		output = {}
		item = value
		start = start_or_finish
		size = finish
		if finish == nil 
			start = 1
			size = start_or_finish
		for i=start, size 
			output[i] = item
		return output
	fill_empty: (start_or_finish, finish) =>
		output = {}
		start = start_or_finish
		size = finish
		if finish == nil 
			start = 1
			size = start_or_finish
		for item=start, size
			output[item] = item
		return output
	remove: (obj, callback) =>
		output = {}
		copy = @deep_copy(obj)
		for i=1, #copy 
			value = copy[i]
			if callback(value, i) 
				table.insert(output, value)
				index = @index_of(obj, value)
				table.remove(obj, index)
		return output
	counter: (obj) =>
		output = {}
		for i=1, #obj 
			value = obj[i]
			output[value] = (output[value] and output[value] or 0) + 1
		return output
	intersect: (obj1, obj2) =>
		output = {}
		count1 = @counter(obj1)
		count2 = @counter(obj2)
		for k, v in pairs(count1) 
			if count2[k] 
				new_array = @fill(
					k,
					@lowest_value(v, count2[k])
				)
				@multiple_inserts(output, new_array)
		return output
	from_pairs: (obj) =>
		output = {}
		for i=1, #obj 
			item = obj[i]
			output[item[1]] = item[2]
		return output
	each: (obj, callback) => [callback(obj[i], i) for i=1, #obj] and true
	reverse_each: (obj, callback) => [callback(obj[i], i) for i = #obj, 1, -1 ] and true
	chunk: (array, size) =>
		t = {}
		size = size == 0 and 1 or size or 1
		c, i = 1, 1
		while true
			t[i] = {}
			for j = 1, size
				@push(t[i], array[c])
				c = c + 1
			if Utils\gt(c, #array)
				break
			i = i + 1
		return t
	push: (array, value) => table.insert(array, value)
	push_new: (array, value) => 
		t = Array\slice(array)
		table.insert(t, value)
		return t
	compact: (array) => [item for _, item in pairs(array) when item]
	concat_props: (...) =>
		tmp = Utils\to_table(...)
		array = {}
		@each(tmp, (item) -> array = @concat(array, item))
		return array
	difference: (array, ...) => 
		subtracting = @concat(...)
		@filter(array, (item) -> not @includes(subtracting, item))
	difference_by: (array, ...) =>
		tmp = Utils\to_table(...)
		iteratee = @pop(tmp)
		subtracting = {} 
		@each(tmp, (item) -> subtracting = @concat(subtracting, item))
		handler = Utils\identity
		if Utils\is_string(iteratee) 
			handler = (obj) -> obj[iteratee]
		if Utils\is_function(iteratee) 
			handler = (...) -> iteratee(...)
		minuend = @map(array, (item) -> handler(item))
		subtracting = @map(subtracting, (item) ->return handler(item))
		return @filter(array, (_, index) -> not @includes(subtracting, minuend[index]))
	drop: (array, n) =>
		n = n or 1
		return @slice(array, n + 1)
	shift: (array) => table.remove(array, 1)
	unshift: (p, x) =>
		table.insert(p, 1, x)
		return p
	drop_right: (array, n) =>
		n = n or 1
		return @slice(array, nil, #array - n)
	pop: (array) => table.remove(array, #array)
	drop_rightwhile: (array, predicate, selfArg) =>
		return drop_while(array, predicate, selfArg, #array, -1, true)
	drop_while: (array, predicate, selfArg) =>
		return drop_while(array, predicate, selfArg, 1, 1)
	enqueue: (array, value) =>
		return table.insert(array, 1, value)
	fill: (array, value, start, stop) =>
		start = start or 1
		stop = stop or #array
		for i=start, stop, start > stop and -1 or 1
			array[i] = value
		return  array
	find_index: (array, predicate, selfArg) =>
		return find_index(array, predicate, selfArg, 1, 1)
	find_last_index: (array, predicate, selfArg) =>
		return find_index(array, predicate, selfArg, #array, -1)
	first: (array) => array[1]
	head: (...) => @first(...)
	flatten: (array, isDeep) =>
		t = {}
		@each(array, (item) -> 
			if Utils\is_table(item) 
				childeren = if isDeep then @flatten(item) else item
				@each(childeren, (value) -> 
					@push(t, value)
				)
			else
				@push(t, item)
		)
		return t
	flatten_deep: (array) => @flatten(array, true)
	fromPairs: (array) => 
		t = {}
		@each(array, (item) -> 
			t[item[1]] = item[2]
		)
		return t
	indexOf: (array, value, fromIndex) => @find_index(array, (n) -> n == value)
	initial: (array) =>
		return @slice(array, nil, #array - 1)
	intersection: (array, ...) =>
		array_others = @concat(...)
		return @filter(array, (item) -> @includes(array_others, item))
	intersection_by: (array, ...) => 
		tmp = Utils\to_table(...)
		iteratee = @pop(tmp)
		subtracting = {} 
		@each(tmp, (item) -> subtracting = @concat(subtracting, item))
		handler = Utils\identity
		if Utils\is_string(iteratee) 
			handler = (obj) -> obj[iteratee]
		if Utils\is_function(iteratee) 
			handler = (...) -> iteratee(...)
		minuend = @map(array, (item) -> handler(item))
		subtracting = @map(subtracting, (item) ->return handler(item))
		return @filter(array, (_, index) -> @includes(subtracting, minuend[index]))
	join: (array, separator) => Utils\to_str(separator)(array)
	last_index_of: (array, value, fromIndex) =>
		return @find_last_index(array, (n) -> n == value)
	nth: (array, index = 1) =>
		len = @length(array)
		if (index > 0 and index <= @length(array))
			return array[index]
		elseif (index < 0 and Math.abs(index) <= len)
			len += 1 
			return array[len + index]
		return -1
	pull: (array, ...) =>
		i = 1
		while not Utils\is_nil(array[i])
			for _, v in ipairs(Utils\to_table(...))
				if array[i] == v  
					table.remove(array, i)
					return array
			i = i + 1
		return array
	pull_all: (array, array_others) =>
		i = 1
		while not Utils\is_nil(array[i])
			for _, v in ipairs(array_others)
				if array[i] == v  
					table.remove(array, i)
					return array
			i = i + 1
		return array
	pull_at: (array, ...) =>
		t = {}
		tmp = Utils\to_table(...)
		table.sort(tmp, (a, b) -> Utils\gt(a, b))
		@each(tmp, (item) -> 
			@enqueue(t, table.remove(array, item))
		)
		return t
	remove: (array, predicate) =>
		t = {}
		c = 1
		predicate = predicate or Utils\identity
		while not Utils\is_nil(array[c])
			if predicate(array[c], c, array)
				@push(t, table.remove(array, c))
				return t
			c = c + 1
		return t
	rest: (array) =>
		return @slice(array, 2, #array)
	reverse: (array) =>
		t = {}
		for _, v in ipairs(array)
			@enqueue(t, v)
		return t
	tail: (array) => 
		@shift(array)
		array
	take: (array, n = 1) => @slice(array, 1, n)
	take_right: (array, n = 1) => @slice(array, #array - n +1)
	take_rightwhile: (array, predicate, selfArg) => take_while(array, predicate, selfArg, #array, -1, true)
	take_while: (array, predicate, selfArg) =>
		return take_while(array, predicate, selfArg, 1, 1)
	union: (...) =>
		tmp = Utils\to_table(...)
		t = {}
		@each(tmp -> (array) -> 
			@each(array, (value) -> 
				if @indexOf(t, value) == -1
					@push(t, value)
			)
		)		
		return t
	union_by: (...) =>
		-- after
		return ...
	xor: (array, ...) => 
		array_other = @concat_props(...)
		@concat(
			@filter(array, (item) -> not @includes(array_other, item))
			@filter(array_other, (item) -> not @includes(array, item))
		)
	zip_all: (...) =>
		t = {}
		for i, array in ipairs(Utils\to_table(...))
			for j, v in ipairs(array)  
				t[j] = t[j] or {}
				t[j][i] = v
		return t
	args: (value) =>
		if Utils\is_table(value)
			table.unpack(value) 
		else 
			table.unpack({value})
	for_each: (...) => @each(...)
	
--



class String extends string
	each: (str, callback) => 
		index = 1
		str\gsub(".", (char) ->
			callback(char, index)
			index += 1
		)
	map: (str, callback) => 
		new_str = "" 
		index = 1
		str\gsub(".", (char) ->
			new_str += "#{callback(char, index)}"
			index += 1
		)
		return new_str
	map_array: (str, callback) => 
		array = {} 
		index = 1
		str\gsub(".", (char) ->
			Array\push(array, callback(char, index))
			index += 1
		)
		return array
	hash: (str, str_search) => str\gmatch"#{str_search}" != nil
	hash_index: (str, str_search) => 
		_hash_index = -1
		if not @hash(str, str_search)
			return _hash_index
		index = 1
		len = #str_search
		_hash = false
		index_true = 0
		str\gsub(".", (char) ->
			if not _hash 
				if (char == @nth(str_search, index_true + 1))
					index_true += 1
				else 
					index_true = 0
				if index_true == len
					_hash = true
				index += 1
		)
		index_start = index - index_true
		index_end = index - 1
		return if _hash then index_start, index_end else -1
	nth: (str, index) => @.sub(str, index, index)
	substring: (str, ...) => str\sub(...)
	length: (str) => @.len(str)
	byte: (str) => @.byte(str)
	byte_index: (str, index) => str\byte(index)
	bytes: (str) => @map_array(str, @byte)
	replace: (str, search, replace) => @.gsub(str, search, replace) 
	constant: (value) =>
		return @func(value)
	identity: (...) => ... 
	iterRight: (value) =>
		if Utils\is_string(value)
			i = #value + 1
			return () ->
				if Utils\gt(i, 1) 
					i = i - 1
					c = value:sub(i, i)
					return i, c
		elseif Utils\is_table(value) 
			return Collection\iter_collection(value, true)
		else
			return () -> 
	print: (...) =>
		t =  Utils\to_table(...)
		for i, v in ipairs(t) 
			t[i] = Utils\to_string(t[i])
		
		return print(Utils\args(t))
	range: (start, ...) =>
		start = start 
		args =  Utils\to_table(...)
		a, b, c
		if #args == 0 
			a = 1
			b = start
			c = 1
		else
			a = start
			b = args[1] 
			c = args[2] or 1
		t = {}
		for i = a, b, c
			Array\push(t, i)
		return t
	keys: (p) =>
		t = {}
		for k in ipairs(p) 
			t[#t + 1] = k
		return t
	is_empty: (p) =>
		for k, v in pairs(p)
			return false
		return true
	sleep: (seconds) =>
		time = os.clock!
		while os.clock! - time <= seconds do nil
	-- Escribe cada carácter de text en 1/rate.
	slow_write: (text, rate) =>
		text = text and (tostring text)   or ""
		rate = rate and 1/(tonumber rate) or 1/20
		for n=1, text\len!
			@sleep rate
			io.write text\sub n,n
			io.flush!
	-- Similar a, slow_writepero agrega una nueva línea al final
	slow_print: (text, rate) =>
		@slow_write(text, rate)
		print!
	-- Comprueba si textcomienza cn start
	starts_with: (text, start) => text\sub(1, start\len()) == start
	-- Comprueba si texttermina conends
	ends_with: (text, ends) => (text\sub -(ends\len!)) == ends
	-- Hace que el primer carácter sea mayúsculo
	first_upper: (text) => text\gsub "^%l", string.upper if text
	-- Hace que el primer carácter alfabético sea mayúsculo
	first_word_upper: (text) => text\gsub "%a",  string.upper, 1 if text
	-- Hace que el primer carácter sea minúsculo
	first_lower: (text) => text\gsub "^%u", string.lower if text
	-- Hace que el primer carácter alfabético sea minúsculo
	first_word_lower: (text) => text\gsub "%a",  string.lower, 1 if text
	-- Hace que el primer carácter de todas las palabras sea mayúscula
	title_case: (text) => text\gsub "(%a)([%w_']*)", (first, rest) -> first\upper! .. rest\lower! if text
	-- Hace que todos los caracteres sean minúsculas
	all_lower: (text) => text\gsub "%f[%a]%u+%f[%A]", string.lower if text
	-- Hace que todos los caracteres sean mayúsculas
	all_upper: (text) => text\gsub "%f[%a]%l+%f[%A]", string.upper if text
	-- URL codifica una cadena
	url_encode: (text) => if text
		text = text\gsub "\n", "\r\n"
		text = text\gsub "([^%w %-%_%.%~])", (c) ->
			("%%%02X")\format string.byte c
		text = text\gsub " ", "+"
	-- URL-decodifica una cadena
	url_decode: (text) => if text
		text = text\gsub "+", " "
		text = text\gsub "%%(%x%x)", (h) ->
			return string.char tonumber h, 16
		text = text\gsub "\r\n", "\n"
	-- Elimina los espacios en blanco al final de la cadena.
	trimr: (text) => text\match "(.-)%s*$" if text
	-- Elimina los espacios en blanco al principio de la cadena.
	triml: (text) => text\match "^%s*(.*)" if text
	-- Elimina los espacios en blanco al principio y al final de la cadena
	trim: (text) => trimr triml text if text
	-- Divide una cadena usando sepun separador un máximo de maxveces. Si plaines cierto, se escapará el separador.
	split: (text, sep=" ", max, plain) =>
		sep = " " if sep == ""
		parts = {}
		if text\len! > 0
			max = max or -1
			nf, ns = 1, 1
			nf, nl = text\find sep, ns, plain
			while nf and (max != 0)
				parts[nf] = text\sub ns, nf-1
				nf += 1
				ns = nl + 1
				nf, nl = text\find sep, ns, plain
				nm -= 1
			parts[nf] = text\sub ns
		return parts
	-- Imprime => #{text}en color color(de ansicolors), si no se detectan ansicolors, se imprimirá claramente.
	-- Si fullse establece en falso, solo =>se coloreará.
	_arrow: (text, full=true) => "=> #{if not full then "%{reset}" else ""}#{text}"
	-- Similares a arrow, pero con diferentes prefijos.
	_dart: (text, full=true) => "-> #{if not full then "%{reset}" else ""}#{text}"
	_pin: (text, full=true) => "-- #{if not full then "%{reset}" else ""}#{text}"
	_bullet: (text, full=true) => " * #{if not full then "%{reset}" else ""}#{text}"
	_quote: (text, full=true) => " > #{if not full then "%{reset}" else ""}#{text}"
	_title: (text, full=true) => "== #{if not full then "%{reset}" else ""}#{text}"
	_error: (text, full=true) => "!! #{if not full then "%{reset}" else ""}#{text}"
	-- Equivalente a print string.format text, ...
	printf: (text, ...) => print string.format text, ...



--



class Collection
	filter = (collection, predicate, selfArg, reject) ->
		t = {}
		for k, v in lodash_\iter(collection)
			check = Array\call_iteratee(predicate, selfArg, v, k, collection)
			if reject  
				if not check 
					lodash_\push(t, v)
			else
				if check 
					lodash_\push(t, v)
		return t
	handler_iteratee = (iteratee) -> 
		handler = Utils\identity
		if Utils\is_string(iteratee) 
			handler = (obj) -> obj[iteratee]
		if Utils\is_function(iteratee) 
			handler = (...) -> iteratee(...)
		return handler

	get_sorted_keys: (collection, desc) ->
		sortedKeys = {} 
		for k, v in pairs(collection)
			table.insert(sortedKeys, k)
		if desc 
			table.sort(sortedKeys, lodash_\gt)
		else
			table.sort(sortedKeys, lodash_\lt)
		return sortedKeys
	iter_collection: (table, desc) =>
		sortedKeys = get_sorted_keys(table, desc)
		i = 0
		return () ->
			if lodash_\lt(i, #sortedKeys) 
				i = i + 1
				key = sortedKeys[i]
				return key, table[key]
	
	nth: (object, key) => object[key]
	nth: (object, key) => object[key]
	hash_key: (object, key) =>
		value = false
		if @nth(object, key) then 
			value = true
		else 
			@each(object, (_, key_loca) -> 
				if Utils\to_string(key) == Utils\to_string(key_loca) 
					value = true
			)
			return value
	for_each: (...) => @each(...)
	each: (...) => @map(...) and true
	map: (object, callback) => [callback(item, key) for key, item in pairs(object)]
	map_reverse: (obj, callback) => [callback(obj[i], i) for i = #obj, 1, -1 ]
	for_each_right: (...) => @map_reverse(...) and true
	each_right: (...) => @map_reverse(...) and true
	count_by: (array, iteratee) =>
		object = {}
		handler = handler_iteratee(iteratee)
		Array\each(array, (item) -> 
			value = handler(item)
			if (@hash_key(object, value))
				object[Utils\to_string(value)] += 1
			else
				object[Utils\to_string(value)] = 1
		)
		return object
	hash_item: (object, key, value) =>
		if @hash_key(object, key) 
			if object[key] == value
				return true
		return false
	hash_value: (object, value) =>
		hash_value_ = false
		@each(object, (item) -> 
			if item == value
				hash_value_ = true
		)
		return hash_value_
	every: (array, predicate, callback = Utils\identity) => 
		_every = false
		key = predicate[1]
		value = predicate[2]
		Array\each(array, (object) -> 
			if @hash_item(object, key, value)
				_every = true
				callback(object, key, value)
		)
		return _every
	find_all: (array, predicate) => Array\map(array, (object) -> 
			if predicate(object)
				return object
		)
	find_last: (array, predicate) => 
		o = nil
		Array\map(array, (object) -> 
			if predicate(object)
				o = object
		)
		return o
	find: (array, predicate) => 
		o = nil
		Array\map_reverse(array, (object) -> 
			if predicate(object)
				o = object
		)
		return o
	group_by: (array, iteratee) =>
		object = {}
		handler = handler_iteratee(iteratee)
		Array\each(array, (item) -> 
			value = handler(item)
			if (@hash_key(object, value))
				object[Utils\to_string(value)] = Array\push_new(object[Utils\to_string(value)], item)
			else
				object[Utils\to_string(value)] = {item}
		)
		return object
	includes: (object, value, fromIndex=false) =>
		_includes = false
		if Utils\is_string(object) 
			if fromIndex
				index = String\hash_index(object, value)
				return index == fromIndex
			else
				return String\hash(object, value)
		
		try(() -> 
			if fromIndex
				_includes = @hash_item(object, fromIndex, value)
			else
				_includes = @hash_value(object, value)
				
			if _includes == nil
				error()
		).catch((err) -> 
			Array\map(object, (item, index) ->
				if fromIndex and value == item and index == fromIndex
					_includes = true
				elseif value == item
					_includes = true
			)
		)
		return _includes
	invoke_map: (array, iteratee, arg1, arg2) =>
		iteratee = iteratee or Utils\identity
		return Array\map(array, (item) -> 
			return iteratee(item, arg1, arg2)
		)
	key_by: (array, iteratee = Utils\identity) => 
		tmp = Utils\to_table!
		Array\each(array, (item) ->
			key = iteratee(item)
			if key
				if tmp["#{key}"]
					array, object = Utils\array_or_object(tmp["#{key}"])
					if array
						tmp["#{key}"] = Array\concat(tmp["#{key}"], {item})
					elseif object
						tmp["#{key}"] = Array\concat({tmp["#{key}"]}, {item})
				else
					tmp["#{key}"] = item
		)
		return tmp
	iter: (value) =>
		if Utils\is_string(value) 
			i = 0
			return () ->
				if Utils\lt(i, #value) 
					i = i + 1
					c = value:sub(i, i)
					return i, c
		else
			return Collection\iter_collection(value) 
	some: (collection, predicate, selfArg) =>
		for k, v in @iter(collection)
			if Array\call_iteratee(predicate, selfArg, v, k, collection) 
				return true
		return false
	reject: (collection, predicate, selfArg) =>
		return filter(collection, predicate, selfArg, true)
	sample: (collection, n) =>
		n = n or 1
		t = {}
		keys = @keys(collection)
		for i=1, n        
			pick = keys[Number\random(1, #keys)]
			Array\push(t, @get(collection, {pick}))
		return #t == 1 and t[1] or t
	size: (collection) =>
		c = 0
		for k, v in @iter(collection)
			c = c + 1
		return c
	sort: (p, f) =>
		f = f or (a, b) -> a < b
		t = Collection\value(p)
		table.sort(t, f)
		return t
	value: (p) =>
		t = {}
		for v in Utils\iter(p)
			t[#t + 1] = v
		return t
	sort_by: (collection, predicate, selfArg) =>
		t ={}
		empty = true
		previous
		for k, v in @iter(collection) 
			if empty  
				Array\push(t, v)
				previous = call_iteratee(predicate, selfArg, v, k, collection)            
				empty = false
			else
				r = call_iteratee(predicate, selfArg, v, k, collection)
				if Utils\lt(previous, r) 
					table.insert(t, v)
					previous = r
				else
					table.insert(t, #t, v)
		return t
	keys: (object) =>
		if Utils\is_table(object)
			return @get_sorted_keys(object)
		elseif Utils\is_string(object) 
			keys = {}
			for i=1, #object
				keys[i] = i
			return keys
	get: (object, path, defaultValue) =>
		if Utils\is_table(object) 
			value = object
			c = 1
			while not Utils\is_nil(path[c])
				if not Utils\is_table(value)
					return defaultValue 
				value = value[path[c]]
				c = c + 1
			return value or defaultValue
		elseif Utils\is_string(object) 
			index = path[1]
			return object:sub(index, index)
	has: (object, path) =>
		obj = object
		c = 1
		exist = true
		while not Utils\is_nil(path[c])
			obj = obj[path[c]]
			if Utils\is_nil(obj) 
				exist = false
				break
			c = c + 1
		return exist
	values: (p) =>
		t = {}
		for k, v in pairs(p)
			t[#t + 1] = v
		return t
--



-- Push  Biblioteca Lua que implementa propiedades observables similares a knockout.js
Knockout = (() ->
	recorders = {}
	mt =  
		__tostring: => "Property " .. @name .. ": " .. tostring(@__value)
		__call: (nv) =>
			if nv != nil and nv != @__value
				@__value = nv
				p nv for p in pairs @__tos
			else if nv == nil
				r @ for r in pairs recorders
			return @__value
		__index:
			push_to: (pushee) => 
				@__tos[pushee] = pushee
				return -> @__tos[pushee] = nil -- remover
			peek: => @__value
			writeproxy: (proxy) =>
				setmetatable {},
					__tostring: (t) -> "(proxied) " .. tostring @
					__index: @
					__call: (t, nv) -> 
						if nv != nil then @(proxy(nv)) else @!


	property = (v, name="<unnamed>") ->
		return setmetatable {
			__value: v
			__tos: {}
			:name
		}, mt


	record_pulls = (f) ->
		sources = {}
		rec = (p) -> sources[p] = p
		recorders[rec] = rec
		status, res = pcall f
		recorders[rec] = nil
		if not status
			false, res
		else
			sources, res


	readonly = => 
		@writeproxy (nv) ->
			error "attempted to set readonly property '" .. tostring(@) .. "' with value " .. tostring(nv)


	computed = (reader, writer, name = "<unnamed>") ->
		p = property nil, name
		p.__froms = {}
		update = ->
			if not p.__updating
				p.__updating = true
				newfroms, res = record_pulls reader
				if not newfroms
					p.__updating = false
					error res
				-- remove redundant sources
				for f, remover in pairs p.__froms
					if not newfroms[f]
						p.__froms[f] = nil
						remover!
				-- add Property sources
				for f in pairs newfroms
					if not p.__froms[f]
						p.__froms[f] = f\push_to update
				p res
				p.__updating = false

		update!
		if not writer then readonly p else p\writeproxy (nv) ->
			if not p.__updating
				p.__updating = true
				status, res = pcall writer, nv
				p.__updating = false
				if status then res else error res

	return {
	:property
	:readonly
	:computed
	:record_pulls
	})()
--



Promise = (() -> 
	_Promise, promise = {}, {}

	-- andThen replacer
	--  1) replace standard .then() when promised

	PENDING = {}
	nil_promise = {}

	promised = (value, action) ->
		ok, result = pcall(action, value)
		return ok and _Promise.resolve(result) or _Promise.reject(result) -- .. '.\n' .. debug.traceback())


	promised_s = (self, onFulfilled) ->
		return onFulfilled and promised(self, onFulfilled) or self

	promised_y = (self, onFulfilled) ->
		return onFulfilled and promised(self[1], onFulfilled) or self

	promised_n = (self, _, onRejected) ->
		return onRejected and promised(self[1], onRejected) or self

	-- inext() list all elementys in array
	--	*) next() will list all members for table without order
	--	*) @see iter(): http://www.lua.org/pil/7.3.html
	inext = (a, i) ->
		i = i + 1
		v = a[i]
		if v 
			return i, v

	-- put resolved value to p[1], or push lazyed calls/object to p[]
	--	1) if resolved a no pending promise, direct call promise.andThen()
	resolver = (this, resolved, sure) ->
		typ = type(resolved)
		if (typ == 'table' and resolved.andThen)
			lazy = {this, (value) -> resolver(this, value, true), (reason) -> resolver(this, reason, false)}
			if resolved[1] == PENDING
				table.insert(resolved, lazy) -- lazy again
			else -- deep resolve for promise instance, until non-promise
				resolved\andThen(lazy[2], lazy[3])
		else -- resolve as value
			if this[1] == PENDING -- put value once only
				this[1], this.andThen = resolved, sure and promised_y or promised_n
			for i, lazy, action in inext, this, 1 -- extract 2..n
				action = (sure and lazy[2]) or (not sure and lazy[3])
				pcall(resolver, lazy[1], action and promised(resolved, action) or (sure and _Promise.resolve or _Promise.reject)(resolved), sure)
				this[i] = nil

	-- for Promise.all/race, ding coroutine again and again
	coroutine_push = (co, promises) ->
		-- push once
		coroutine.resume(co)

		-- and try push all
		--	1) resume a dead coroutine is safe always.
		-- 	2) if promises[i] promised, skip it
		resume_y = (value) -> coroutine.resume(co, true, value)
		resume_n = (reason) -> coroutine.resume(co, false, reason)
		for i = 1, #promises
			if promises[i][1] == PENDING
				promises[i]\andThen(resume_y, resume_n)

	-- promise as meta_table of all instances
	promise.__index = promise
	-- reset __len meta-method
	--	1) lua 5.2 or LuaJIT 2 with LUAJIT_ENABLE_LUA52COMPAT enabled
	--	2) need table-len patch in 5.1x, @see http://lua-users.org/wiki/LuaPowerPatches
	-- promise.__len = function() return 0 end

	-- promise for basetype
	number_promise = setmetatable({andThen: promised_y}, promise)
	true_promise   = setmetatable({andThen: promised_y, true}, promise)
	false_promise  = setmetatable({andThen: promised_y, false}, promise)
	number_promise.__index = number_promise
	nil_promise.andThen = promised_y
	getmetatable('').__index.andThen = promised_s
	getmetatable('').__index.catch = (self) -> self
	setmetatable(nil_promise, promise)

	------------------------------------------------------------------------------------------
	-- instnace method
	--	1) promise:andThen(onFulfilled, onRejected)
	--	2) promise:catch(onRejected)
	------------------------------------------------------------------------------------------

	promise.andThen = (onFulfilled, onRejected) ->
		lazy = {{PENDING}, onFulfilled, onRejected}
		table.insert(self, lazy)
		return setmetatable(lazy[1], promise) -- <lazy[1]> is promise2

	promise.catch = (onRejected) ->
		return self\andThen(nil, onRejected)
	

	------------------------------------------------------------------------------------------
	-- class method
	--	1) Promise.resolve(value)
	--	2) Promise.reject(reason)
	--	3) Promise.all()
	------------------------------------------------------------------------------------------

	-- resolve() rules:
	--	1) promise object will direct return
	-- 	2) thenable (with/without string) object
	-- 		- case 1: direct return, or
	--		- case 2: warp as resolved promise object, it's current selected.
	-- 	3) warp other(nil/boolean/number/table/...) as resolved promise object
	_Promise.resolve = (value) ->
		valueType = type(value)
		if valueType == 'nil'
			return nil_promise
		elseif valueType == 'boolean'
			return value and true_promise or false_promise
		elseif valueType == 'number'
			return setmetatable({(value)}, number_promise)
		elseif valueType == 'string'
			return value
		elseif (valueType == 'table') and (value.andThen ~= nil)
			return value.catch ~= nil and value or setmetatable({catch:promise.catch}, {__index:value})
		else
			return setmetatable({andThen:promised_y, value}, promise)

	_Promise.reject = (reason) ->
		return setmetatable({andThen:promised_n, reason}, promise)

	_Promise.all = (arr) ->
		this, promises, count = setmetatable({PENDING}, promise), {}, #arr
		co = coroutine.create(() ->
			i, result, sure, last = 1, {}, true, 0
			while i <= count
				promise, typ, reason, resolved = promises[i], type(promises[i])
				if typ == 'table' and promise.andThen and promise[1] == PENDING
					sure, reason = coroutine.yield()
					if not sure
						return resolver(this, {index: i, reason: reason}, sure)
					-- dont inc <i>, continue and try pick again
				else
					-- check reject/resolve of promsied instance
					--	*) TODO: dont access promise[1] or promised_n
					sure = (typ == 'string') or (typ == 'table' and promise.andThen ~= promised_n)
					resolved = (typ == 'string') and promise or promise[1]
					if not sure
						return resolver(this, {index: i, reason: resolved}, sure)
					-- pick result from promise, and push once
					result[i] = resolved
					if result[i] ~= nil
						last = i
					i = i + 1
			-- becuse 'result[x]=nil' will reset length to first invalid, so need reset it to last
			-- 	1) invalid: setmetatable(result, {__len=function() retun count end})
			-- 	2) obsoleted: table.setn(result, count)
			resolver(this, sure and {unpack(result, 1, last)} or result, sure)
		)

		-- init promises and push
		for i, item in ipairs(arr)
			promises[i] = _Promise.resolve(item)
		coroutine_push(co, promises)
		return this

	_Promise.race = (arr) ->
		this, result, count = setmetatable({PENDING}, promise), {}, #arr
		co = coroutine.create(() ->
			i, sure, resolved = 1
			while i < count
				promise, typ = result[i], type(result[i])
				if typ == 'table' and promise.andThen and promise[1] == PENDING
					sure, resolved = coroutine.yield()
				else
					-- check reject/resolve of promsied instance
					--	*) TODO: dont access promise[1] or promised_n
					sure = (typ == 'string') or (typ == 'table' and promise.andThen ~= promised_n)
					resolved = typ == 'string' and promise or promise[1]
				-- pick resolved once only
				break
			resolver(this, resolved, sure)
		)

		-- init promises and push
		for i, item in ipairs(arr)
			promises[i] = _Promise.resolve(item)
		coroutine_push(co, promises)
		return this

	------------------------------------------------------------------------------------------
	-- constructor method
	--	1) Promise.new(func)
	--		(*) new() will try execute <func>, but andThen() is lazyed.
	------------------------------------------------------------------------------------------
	_Promise.new = (func) ->
		this = setmetatable({PENDING}, promise)
		ok, result = pcall(func, (value) -> resolver(this, value, true), (reason) -> resolver(this, reason, false))
		return ok and this or _Promise.reject(result) -- .. '.\n' .. debug.traceback())

	return _Promise
	
	)()
-- 




