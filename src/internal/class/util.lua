local app=_ENV.app;
local ALLOW_WRITING=false;
local WARNINGS=true;
return function(classes)
	local show_warnings = function (bool) WARNINGS = bool end
	local allow_writing_to_objects = function (bool) ALLOW_WRITING = bool end
	local writing_allowed = function () return ALLOW_WRITING end
	local warning = function (current_warning, type_warning) if WARNINGS then
		local err = "[WARNING] - "..current_warning.."\n";
		if app.isUIAvailable then app.alert(err) end
		error(err, type_warning);
	end end
	local compare_interface_names = function (object_class_name, class_name)
		local interfaces = classes[object_class_name].implements;
		if interfaces then for _, interface in pairs(interfaces) do if interface == class_name then
			return true;
		end end end;
		return false;
	end
	local compare_object_entries = function (object_class_name, class_name)
		local equals = object_class_name == class_name;
		if equals then
			return true;
		end
		equals = compare_interface_names(object_class_name, class_name);
		if equals then
			return true;
		end
		local parent = classes[object_class_name].extends;
		equals = parent == class_name;
		return equals;
	end
	local is = function (object, class_name)
		local equals
		if type(object) == "table" and object.get_class and type(object.get_class) == "function" then
			local object_class_name = object.get_class()
			while object_class_name do
				equals = compare_object_entries(object_class_name, class_name);
				if equals then return true end
				object_class_name = classes[object_class_name].extends;
			end
			return false;
		end
		return type(object) == class_name;
	end
	return {
		warning = warning,
		show_warnings = show_warnings,
		allow_writing_to_objects = allow_writing_to_objects,
		writing_allowed = writing_allowed,
		is = is
	}
end