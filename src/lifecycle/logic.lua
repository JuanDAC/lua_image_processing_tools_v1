local TEXTS=_ENV.TEXTS;
local app=_ENV.app;
local Fun=_ENV.Fun;
local D_type=_ENV.D_type;
local import_module=_ENV.import_module;
local Interface=_ENV.Interface;
local return_true = _ENV.return_true;

-- local Fun=_ENV.Fun;
-- logicals
local factory_check_toogle=D_type {"table", {"function", "nil"}} {function (ids, mananger_event)
	if type(mananger_event)~="function" then mananger_event = return_true end
	return function (config, event)
		local visible=config.data[config.self_id];
		Fun.iter(ids):each(D_type {"string"} {function (id) if mananger_event(config, event, id, visible) then
			config.user_interface:modify{ id=id; visible=visible; };
		end end});
		return visible;
	end;
end};
local set_color=D_type {"function"} {function (callback_color) return D_type {"string", {"function", "nil"}} {function (id, mananger_event) return function (config, event)
	if type(mananger_event)~="function" then mananger_event = return_true end
	if mananger_event(config, event) then config.user_interface:modify{ id=id; color=callback_color(config, event); } end
end end} end};
local set_color_fg=(function () return app.fgColor end);
local set_color_bg=(function () return app.bgColor end);
local global_functions = {
	factory_check_toogle=factory_check_toogle,
	set_color=set_color,
	set_color_fg=set_color_fg,
	set_color_bg=set_color_bg,
};
local COLOR_COSNTRUCT = import_module("interface.color")(global_functions);
local FILTER_COSNTRUCT = import_module("interface.filter")(global_functions);

local HOME_COSNTRUCT={
	title=TEXTS.home.title;
	onclose=(function () end);
	-- position={
	-- 	x=120;
	-- 	y=300;
	-- };
	structure={
		{
			type="separator";
			content={
				text=TEXTS.home.separator_menu.text;
				id="separator_menu";
			};
		},
		{
			type="button";
			content={
				id="submit_gadgets";
				text=TEXTS.home.submit_gadgets.text;
				selected=false;
				newrow=true;
				onclick=function(config, event) app.alert(tostring(config).." "..tostring(event)) end;
			};
		},
		{
			type="button";
			content={
				id="submit_color";
				text=TEXTS.home.submit_color.text;
				selected=false;
				newrow=true;
				onclick=(function() Interface.USER_INTERFACE(COLOR_COSNTRUCT) end);
			};
		},
		{
			type="button";
			content={
				id="submit_adjustment";
				text=TEXTS.home.submit_adjustment.text;
				selected=false;
				newrow=true;
				onclick=function(config, event) app.alert(tostring(config).." "..tostring(event)) end;
			};
		},
		{
			type="button";
			content={
				id="submit_transform";
				text=TEXTS.home.submit_transform.text;
				selected=false;
				newrow=true;
				onclick=function(config, event) app.alert(tostring(config).." "..tostring(event)) end;
			};
		},
		{
			type="button";
			content={
				id="submit_filters";
				text=TEXTS.home.submit_filters.text;
				selected=false;
				newrow=true;
				onclick=(function() Interface.USER_INTERFACE(FILTER_COSNTRUCT) end);
			};
		},
		{
			type="button";
			content={
				id="submit_layer";
				text=TEXTS.home.submit_layer.text;
				selected=false;
				newrow=true;
				onclick=function(config, event) app.alert(tostring(config).." "..tostring(event)) end;
			};
		},
		{
			type="button";
			content={
				id="submit_animation";
				text=TEXTS.home.submit_animation.text;
				selected=false;
				newrow=true;
				onclick=function(config, event) app.alert(tostring(config).." "..tostring(event)) end;
			};
		},
		{
			type="button";
			content={
				id="submit_objects";
				text=TEXTS.home.submit_objects.text;
				selected=false;
				newrow=true;
				onclick=function(config, event) app.alert(tostring(config).." "..tostring(event)) end;
			};
		},
		{
			type="button";
			content={
				id="submit_3d";
				text=TEXTS.home.submit_3d.text;
				selected=false;
				newrow=true;
				onclick=function(config, event) app.alert(tostring(config).." "..tostring(event)) end;
			};
		},
	};
};


return {
	HOME_COSNTRUCT=HOME_COSNTRUCT;
}