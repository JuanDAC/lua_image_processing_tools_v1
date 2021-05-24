local app = _ENV.app;
return function (name_this_script)
  -- local name_this_script="the_best";
  local try
  try=function(try_block)
    local status=true;
    local err=nil;
    if type(try_block)=='function' then
      status, err=xpcall(try_block, debug.traceback);
    end
    local finally;
    finally=function(finally_block, catch_block_declared)
      if type(finally_block)=='function' then
        finally_block();
      end
      if not catch_block_declared and not status then
        return error(err);
      end
    end
    local catch;
    catch=function(catch_block)
    local catch_block_declared=type(catch_block)=='function';
    if not status and catch_block_declared then
      local ex=err or "unknown error occurred";
      catch_block(ex);
    end
    return {
      finally=function(finally_block)
      return finally(finally_block, catch_block_declared);
      end
    }
    end
    return {
    catch=catch,
    finally=function(finally_block)
      return finally(finally_block, false);
    end
    }
  end

	local require;
	local import;
	local addEND;
  do
    local path_separator, user_config_path, popen, open=app.fs.pathSeparator, app.fs.userConfigPath, io.popen, io.open;
    local path_this_script=user_config_path.."scripts"..path_separator..name_this_script..path_separator;
		local path_modules=path_this_script.."lua_modules"..path_separator;
		local path_src=path_this_script.."src"..path_separator;
		local path_libs=path_modules.."lib"..path_separator;
		local lua_version;
		try(function ()
			lua_version=dofile(path_this_script..".luarocks"..path_separator.."default-lua-version.lua")
		end)
		.catch(function ()
			lua_version=_VERSION:gsub("Lua%s", " ");
		end)
		local path_scripts=path_modules.."share"..path_separator.."lua"..path_separator..lua_version..path_separator;
		local path_rocks=path_libs.."luarocks"..path_separator.."rocks-"..lua_version..path_separator;

    local read_file=function (path)
			local file=open(path, "rb");
      if not file then return nil end
      local content=file:read("*a"); -- *a or *all reads the whole file
      file:close();
      return content;
		end
		string.replace_first_from_array=function (self, arr)
			local newStr="";
			for i=1, #self, 1 do
				newStr=newStr..string.sub(self, i, i);
				for _, value in ipairs(arr) do if (type(value)=="string" and newStr==value) then
					newStr="";
				end end
			end
			return newStr;
		end
		string.replace_from_array=function (self, arr, replace)
			for _, value in ipairs(arr) do
        self=self:gsub(value, replace);
      end
      return self;
		end
		string.parse_path=function (self)
			return self:replace_from_array({"/", "\\"}, path_separator)
		end
		local get_package_lib=function (reading_file)
			local package_name;
			try(function ()
				local fileContent=string.match(reading_file, '(package%s+=%s+%".-%")'):gsub("package%s+=", "return");
				package_name=load(fileContent)();
			end)
			.catch(function ()
				package_name=nil;
			end)
			return package_name;
		end
		local get_path_rockspec=function (pathKey, directory, close_files)
			if (type(pathKey) ~="string") then error("Error occurred pathKey don't type string") end
			local to_close_files=function ()
				if (close_files and #close_files > 0) then
					for _, item in ipairs(close_files) do
						item:close();
					end
				end
			end
			local path_rockspecs=popen('dir /b/s "'..directory..'*.rockspec"');

			for path_rockspec in path_rockspecs:lines() do
				local reading_file=read_file(path_rockspec);
				local get_modules;
				try(function ()
					local fileContent=string.match(reading_file, "(modules%s+=.-%})"):gsub("modules%s+=", "return");
					get_modules=load(fileContent);
				end)
				.catch(function ()
					local fileContent=string.match(reading_file, "(build%s+=.-%}%s-%})"):match("(lua%s+=.-%})"):gsub("lua%s+=", "return");
					get_modules=load(fileContent);
				end)
				if (get_modules==nil) then break; end
				local modules=get_modules();
				for key, item in pairs(modules) do
					if (key==pathKey) then
						local path_lib=item;
						local package_name_lib=get_package_lib(reading_file);
						to_close_files();
						path_rockspecs:close();
						return {
							package_name=package_name_lib,
							file=path_lib:replace_first_from_array({"lib/", "lib\\", "src/", "src\\", "src-lua/", "src-lua\\", "lua/", "lua\\"}):parse_path(),
						}
					end
				end
			end
			to_close_files();
			path_rockspecs:close();
		end
		local get_path_dir=function (pathKey, directory)
			if (type(pathKey) ~="string") then error("Error occurred pathKey don't type string") end
			local keys={}
			for value in (pathKey):gmatch("[%w%-]+") do
				keys[#keys + 1]=value;
			end
			if (#keys==0) then error("Error occurred \n-> "..pathKey.." don't valid") end
			local directories_current_lib=popen('dir /s/b /A:D "'..directory..'*'..keys[1]..'*"');
			for directory_lib in directories_current_lib:lines() do
				local current_package=get_path_rockspec(pathKey, directory_lib, {directories_current_lib});
				if (current_package and current_package.file) then
					return current_package;
				end
			end
		end

		local get_path_manifest=function (pathKey, directory)
			local reading_file=read_file(directory.."manifest").."\nreturn modules;";
			local get_modules=nil;
			try(function ()
				get_modules=load(reading_file)();
			end)
			.catch(function ()
				try(function ()
					get_modules=load(reading_file)();
				end);
			end);
			if (get_modules==nil) then return nil; end
			for key, value in pairs(get_modules) do
				if (tostring(key)==tostring(pathKey:gsub("%s", ""))) then
					local path_lib=value[#value]:parse_path();
					local current_package=get_path_rockspec(pathKey, path_rocks..path_lib..path_separator, false);
					if (current_package and current_package.file) then
						return current_package;
					end
				end
			end
		end



		local get_path=function (pathKey)
			local current_package;
			try(function ()
				current_package=get_path_manifest(pathKey, path_rocks);
				if (current_package and current_package.file) then
					return current_package;
				end
				error("Error occurred \n->"..pathKey.." is not a module luarocks");
			end)
			.catch(function ()
				try(function ()
					current_package=get_path_dir(pathKey, path_rocks);
					if (current_package and current_package.file) then
						return current_package;
					end
					error("Error occurred in get_path_dir \n->"..pathKey.." is not a module luarocks");
				end)
				.catch(function ()
					current_package=get_path_rockspec(pathKey, path_rocks, nil);
					if (current_package and current_package.file) then
						return current_package;
					end
					error("Error occurred in get_path_rockspec \n->"..pathKey.." is not a module luarocks");
				end)
			end)
			if (current_package and current_package.file) then
				return current_package;
			end
    end
    require=function(name_file)
			local resolve;
			local current_package=get_path(name_file);
			local file=current_package.file;
			local package_name=current_package.package_name;
			try(function ()
				resolve=dofile(path_scripts..file);
			end)
			.catch(function ()
				try(function ()
					resolve=dofile(path_scripts..package_name..path_separator..file);
				end)
				.catch(function ()
					try(function ()
						resolve=dofile(file);
					end)
					.catch(function (err)
						error("Error occurred \n->"..file.." or \n->"..path_this_script..file.." or \n->"..path_scripts..file.."\n Error: \n->"..tostring(err));
					end)
				end)
			end)
			return resolve;
		end
		do
			try(function ()
				local file_list=dofile(path_src.."package.lua");
				import=function (lib_name)
					if (type(lib_name)=="string") then
						local import_result=nil;
						for key, value in pairs(file_list.dependencies) do
							if (lib_name==key) then
								try(function ()
									import_result=dofile(path_src..(value:parse_path()));
								end)
								.catch(function (e)
									local current_error = ("[Error -> import_module] "..lib_name.." \n"..path_src..(value:parse_path()).." \n"..e);
									if lib_name=="internal.system" then
										app.alert(current_error);
									end
									error(current_error);
									import_result=nil;
								end)
							end
						end
						return import_result;
					end
				end
			end)
			.catch(function (err)
				error("Error occurred: \n->Don't have "..path_src.."packege.lua\nError: \n->"..tostring(err));
			end);
		end
		addEND=function (callback)
				return function (name_file, name)
				if (type(name)=="string") then
					_ENV[name]=callback(name_file);
					_ENV.package.seeall[name]=_ENV[name];
					return _ENV[name];
				else
					return callback(name_file);
				end
			end
		end
	end
	_ENV.loadstring=load;
	_ENV.import_module=addEND(import);
	_ENV.require=addEND(require);
	_ENV.package={seeall={}};
	_ENV.module=function (...)
		package.seeall=table.pack(..., package.seeall);
	end;
end