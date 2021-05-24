local import_module, app = _ENV.import_module, _ENV.app;
local util = import_module("internal.class.util")()
local warning = util.warning;
local writing_allowed = util.writing_allowed;

return function(classes)
	local FORBIDDEN_OPERATORS = {
		__index = true,
		__newindex = true,
		__mode = true,
		__gc = true
	};
	local import = function (name) return classes[name].class end
	local extends = function (name)
		if type(name) ~= "string" then return nil end;
		-- TODO validar que name sea una classe valida
		classes[classes.current_def].extends = name;
	end
	local private = function (structure_table)
		local class_def = classes[classes.current_def];
		if class_def.isInterface then
			warning("Modifier 'private' not allowed in interfaces", 2);
		end
		for key, value in pairs(structure_table) do
			if type(value) == "function" then
				class_def.private_func_defs[key] = value;
			elseif type(value) == "table" and value.abstract_function then
				warning("Abstract methods are currently only allowed in interfaces", 2);
			else
				-- TODO Agregar atributos
				warning("Currently only functions in private definitions are supported", 2);
			end
		end
	end
	local public = function (structure_table)
		local class_def = classes[classes.current_def];
		if class_def.isInterface then
			warning("Modifier 'public' not allowed in interfaces", 2);
		end
		for key, value in pairs(structure_table) do
			if type(value) == "function" then
				class_def.public_func_defs[key] = value;
				class_def.private_func_defs[key] = value;
			elseif type(value) == "table" and value.abstract_function then
				warning("Abstract methods are currently only allowed in interfaces", 2);
			else
				-- TODO Agregar atributos
				warning("Currently only functions in public definitions are supported", 2);
			end
		end
	end
	local static = function (structure_table) for key, value in pairs(structure_table) do
		classes[classes.current_def].static_defs[key] = value
	end end
	local operators = function (structure_table)
		for key, value in pairs(structure_table) do
			if type(value) ~= "function" then
				warning("Operator must be function", 2);
			elseif FORBIDDEN_OPERATORS[key] then
				warning("Operator "..tostring(key).." is not allowed for classes.", 2);
			else
				classes[classes.current_def].operators[key] = value;
			end
		end
	end
	-- TODO is_super
	-- local in_super = function (class_def, key)
	-- 	if class_def.extends then
	-- 		return classes[class_def.extends].public_func_defs[key] ~= nil;
	-- 	end
	-- 	return false
	-- end
	local check_class_exists = function (class) if not classes[class] then
		warning("Referencing non existing class "..class, 3);
	end end
	local function check_if_interfaces_are_implemented(class_name)
		local class_def = classes[class_name];
		local interfaces = class_def.implements;
		if type(class_def.implements) == "string" then
			interfaces = { class_def.implements };
		end
		local interface_def;
		for _, interface in pairs(interfaces) do
			check_class_exists(interface);
			interface_def = classes[interface]
			for func_name, func_def in pairs(interface_def.public_func_defs) do
				if not class_def.public_func_defs[func_name] then
					local var_names = "";
					for _, var_name in pairs(func_def.vars) do var_names = var_names..var_name..", " end
					var_names = string.sub( var_names, 0, string.len(var_names) - 2);
					warning("Class "..class_name.." does not implement abstract method: function "..func_name.."("..var_names..")", 3);
				end
			end
		end
	end
	local get_class_def = function (table)
		local class_def_name = rawget(table, "class_def_name");
		return classes[class_def_name];
	end
	local public_mt = {}
	public_mt.__index = function(t, k)
		local class_def = get_class_def(t);
		local public_func = class_def.public_func_defs[k];
		local private_obj = rawget(t, "private_obj");
		if public_func then return private_obj[k] end
		local static_def = class_def.static_defs[k]
		if static_def then return static_def end
		if class_def.extends then return rawget(private_obj, "super")[k] end
		local private_func = class_def.private_func_defs[k]
		if private_func then warning("Trying to access private method "..tostring(k), 2) end
		if private_obj[k] then warning( "Trying to access private member "..tostring(k), 2) end
		warning("Trying to access non existing member "..tostring(k), 2)
	end
	public_mt.__newindex = function(t, k, v)
		local class_def = get_class_def(t);
		local static_member = class_def.static_defs[k];
		if static_member then
			class_def.static_defs[k] = v;
		elseif writing_allowed() then
			rawset(t, k, v);
			warning("Setting keys for classes from outside is not intended. Objects will not be able to use new keys.");
		else
			warning([[
				Trying to write new index to object.
				Writing is not permitted by default, because __newindex is required for_ the library.
				You can enable writing to objects with allow_writing_to_objects(true), e.g. for_ busted tests.
				Other usages may break the library.
			]]);
		end;
	end;
	local has_operator = function (object, operator)
		return get_class_def(object).operators[operator];
	end
	local factory_operator_has = function (operator)
		return function(lhs, ...)
			if not has_operator(lhs, operator) then return end
			local private_obj = rawget(lhs, "private_obj");
			return private_obj[operator](private_obj, ...);
		end
	end
	public_mt.__add = factory_operator_has("__add");
	public_mt.__sub = factory_operator_has("__sub");
	public_mt.__mul = factory_operator_has("__mul");
	public_mt.__div = factory_operator_has("__div");
	public_mt.__pow = factory_operator_has("__pow");
	public_mt.__concat = function(lhs, rhs)
		local self_obj, other, inverse;
		if type(lhs) == "table" and lhs.get_class then
			self_obj = lhs;
			other = rhs;
			inverse = false;
		elseif type(rhs) == "table" and rhs.get_class then
			self_obj = rhs
			other = lhs;
			inverse = true;
		end
		if has_operator(self_obj, "__concat") then
			local private_obj = rawget(self_obj, "private_obj");
			return private_obj:__concat(other, inverse);
		end
	end
	public_mt.__unm = factory_operator_has("__unm");
	public_mt.__tostring = factory_operator_has("__tostring");
	public_mt.__call = factory_operator_has("__call");
	public_mt.__metatable = false
	local func_storage = nil
	local call_object = nil
	local wrapper_function = function (_, ...) return func_storage(call_object, ...) end
	local private_mt = {}
	private_mt.__index = function(t, k)
		local class_def_name = rawget(t, "class_def_name")
		local class_def = classes[class_def_name]
		local private_func = class_def.private_func_defs[k] or class_def.operators[k]
		if private_func then
			call_object = t;
			func_storage = private_func;
			return wrapper_function;
		end
		local static_def = class_def.static_defs[k];
		if static_def then
			return static_def;
		end
		return rawget(t, k);
	end
	private_mt.__newindex = function(t, k, v)
		local class_def_name = rawget(t, "class_def_name");
		local class_def = classes[class_def_name];
		if class_def.static_defs[k] then
			class_def.static_defs[k] = v;
			return
		end
		rawset(t, k, v);
	end
	local class_body = function (_)
		local class_name = classes.current_def;
		local class_def = classes[class_name];
		local class_mt = {};
		class_mt.__index = function(t, k)
			local current = classes[t.class_name];
			while current do
				local static_member = current.static_defs[k];
				if static_member then
					return static_member;
				end
				current = classes[current.extends];
			end
		end
		if class_def.extends then
			check_class_exists(class_def.extends)
		end
		if class_def.implements then
			check_if_interfaces_are_implemented(class_name)
		end
		class_mt.__call = function(t, ...)
			local current_class_def = classes[t.class_name]
			local private_obj = setmetatable({
				class_def_name = t.class_name,
			}, private_mt)
			if current_class_def.extends then
				local super = import(current_class_def.extends)(...)
				private_obj.super = super
			end
			local constructor = current_class_def.public_func_defs.constructor
			if constructor then
				constructor(private_obj, ...)
			end
			return setmetatable({
				private_obj = private_obj,
				class_def_name = t.class_name,
			}, public_mt)
		end
		class_def.class = setmetatable({class_name = class_name}, class_mt)
		classes.current_def = nil
		return class_def.class
	end
	local function class(name)
		classes.current_def = name
		classes[classes.current_def] = {
			static_defs = {
				get_class = function() return name end;
			},
			private_func_defs = {},
			public_func_defs = {},
			operators = {},
			extends = nil,
			class = nil
		}
		return class_body
	end
	return {
		import = import,
		static = static,
		private = private,
		public = public,
		operators = operators,
		extends = extends,
		class = class
	}
end