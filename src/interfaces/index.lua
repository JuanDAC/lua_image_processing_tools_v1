-- local interface=Pie.interface;
-- local implements=Pie.implements;
local resolution, deep_copy, Fun, TEXTS, languages_option, Rx=_ENV.resolution, _ENV.deep_copy, _ENV.Fun, _ENV.TEXTS, _ENV.languages_option, _ENV.Rx;
local class, public, private, import = _ENV.class, _ENV.public, _ENV.private, _ENV.import;
local app, Rectangle, Dialog = _ENV.app, _ENV.Rectangle, _ENV.Dialog;

local toogle_languages=false;
local menu_bar = Fun.iter({});
local LEFT_BASE_MENU_BAR = 230;
local AXIS_X_BASE_MENU_BAR = 0;
local TOP_BASE_MENU_BAR = -16;

class "USER_INTERFACE" {
	public {
		constructor=function(self, obj_config)
			self.id = tonumber(os.clock());
			self.first_render=false;
			local init_dialog={};
			self.maximize_content={
				id="maximize";
				text=obj_config.title or TEXTS.menu.maximize.text;
				selected=false;
				focus=false;
				onclick=function ()
					menu_bar = menu_bar:filter(function (value) return value.id ~= self.id end);
					if AXIS_X_BASE_MENU_BAR ~= 0 then
						AXIS_X_BASE_MENU_BAR = AXIS_X_BASE_MENU_BAR - self.user_interface.bounds.width;
					end
					self.user_interface:close();
					self:create_interface();
					self.config:onNext(self.previous_bounds);
				end
			};
			self.close_content={
				title=TEXTS.menu.close_content.title;
				text=TEXTS.menu.close_content.text;
				buttons=TEXTS.menu.close_content.buttons;
			};
			local structure=Fun.chain({
				{
					type="separator";
					content={
						text=TEXTS.menu.separator_setting.text;
						id="separator_setting";
					};
				},
				{
					type="combobox";
					content={
						id="languages";
						option=languages_option;
						focus=true;
						visible=toogle_languages;
						options=TEXTS.languages;
					};
				},
				{
					type="button";
					content={
						id="languages_changes";
						text=TEXTS.menu.languages.text;
						selected=false;
						visible=not toogle_languages;
						onclick=function ()
							self.user_interface:modify{
								id="languages";
								visible=true;
							}:modify{
								id="apply_changes";
								visible=true;
							}:modify{
								id="languages_changes";
								visible=false;
							};
						end
					};
				},
				{
					type="button";
					content={
						id="apply_changes";
						text=TEXTS.menu.apply_changes.text;
						selected=false;
						visible=toogle_languages;
						onclick=function ()
							self:update();
						end
					};
				},
				{
					type="button";
					content={
						id="minimize";
						text=TEXTS.menu.minimize.text;
						selected=false;
						newrow=false;
						onclick=function ()
							self:minimize();
						end
					};
				},
				{
					type="button";
					content={
						id="close";
						text=TEXTS.menu.close.text;
						selected=false;
						onclick=function ()
							local alert_content=deep_copy(self.close_content)
							alert_content.text=alert_content.text[languages_option];
							alert_content.title=alert_content.title[languages_option];
							alert_content.buttons=alert_content.buttons[languages_option];
							local result=app.alert(alert_content);
							if (result==1) then
								self.user_interface:close();
							end
						end
					};
				}
			}, deep_copy(obj_config.structure))
			if (type(obj_config.title) ~="nil") then
				init_dialog.title=obj_config.title
			end
			if (type(obj_config.onclose)=="function") then init_dialog.onclose=obj_config.onclose end
			if (type(obj_config.position)=="table") then self.position=obj_config.position end
			if (type(obj_config.structure)=="table") then self.structure_user_interface_components=structure end
			self.show_config={
				wait=false;
			}
			self.init_dialog=init_dialog;
			self:create_interface();
			self:config_create();
			self:defines_user_interface_components();
			self:render();
		end;
	};
	private {
		update_menu_bar = function ()
			AXIS_X_BASE_MENU_BAR = 0;
			menu_bar:enumerate():each(function (index_x, val)
				-- SIZE_BASE_MENU_BAR
				-- AXIS_X_BASE_MENU_BAR =
				-- resolution.CurrentHorizontalResolution
				-- local initial_x = (val.user_interface.bounds.width * (index_x - 1));
				-- local position_x = 0;
				if (index_x > 1) then
					AXIS_X_BASE_MENU_BAR = AXIS_X_BASE_MENU_BAR + val.user_interface.bounds.width;
				end
				local index_y =  math.floor(AXIS_X_BASE_MENU_BAR / (resolution.CurrentHorizontalResolution - LEFT_BASE_MENU_BAR));
				val.user_interface:show { bounds=Rectangle(
					LEFT_BASE_MENU_BAR + (AXIS_X_BASE_MENU_BAR / (index_y+1)),
					(index_y * val.user_interface.bounds.height) + TOP_BASE_MENU_BAR,
					val.user_interface.bounds.width,
					val.user_interface.bounds.height
				); wait=false};
			end);
			-- for index, val in pairs(menu_bar:enumerate()) do
				-- print(index, val);
			-- end;
		end;
		-- add_menu_bar = function (self)
		-- 	-- menu_bar;
		-- 	-- self.user_interface.bounds=Rectangle((resolution.CurrentHorizontalResolution - self.user_interface.bounds.width), 0, self.user_interface.bounds.width, self.user_interface.bounds.height);
		-- end;
		minimize=function (self)
			self.previous_bounds=Rectangle(self.user_interface.bounds.x, self.user_interface.bounds.y, self.user_interface.bounds.width, self.user_interface.bounds.height);
			self.user_interface:close();
			self:create_interface();
			local content=deep_copy(self.maximize_content);
			if (type(self.maximize_content.text)=="table") then
				content.text=content.text[languages_option];
			end
			self.user_interface:button(content);
			self:rendering_update();
			menu_bar = menu_bar:chain({{user_interface = self.user_interface, id = self.id}});
			self:update_menu_bar();
		end;
		create_interface=function (self)
			local init_dialog=deep_copy(self.init_dialog);
			if (type(self.init_dialog.title )=="table") then
				init_dialog.title=self.init_dialog.title[languages_option];
			end
			self.user_interface=Dialog(init_dialog);
		end;
		defines_user_interface_components=function (self)
			-- hacer un redorrido obtyeniendo la clave y el valo las cules sera los metodos y objetos de cnfiguracion respectivasmente
			Fun.each(function (component_structure)
				local content=deep_copy(component_structure.content);
				if (type(self.user_interface[component_structure.type])=="function") then
					if (type(content.label)=="table") then
						content.label=content.label[languages_option];
					end
					if (type(content.text)=="table") then
						content.text=content.text[languages_option];
					end
					if (content.id=="languages") then
						content.option=languages_option;
					end
					if (type(content.options)=="table" and content.id ~= "languages") then
						local options_old = deep_copy(content.options[languages_option]);
						local options_new = {};
						for _, value in pairs(content.options[languages_option]) do
							options_new[#options_new+1] = value;
						end
						content.options = options_new;
						if (type(content.onclick)=="function") then
							local oldOnclick=content.onclick;
							content.onclick=function (...)
								oldOnclick(options_old, ...);
							end;
						end;
					end
					if (type(content.onclick)=="function") then
						local oldOnclick=content.onclick;
						content.onclick=function (...)
							oldOnclick({
								id=content.id,
								self_id=content.id,
								user_interface=self.user_interface,
								data=self.user_interface.data,
								ok=self.user_interface.data.ok,
								-- loader=import("LOADER");
							}, ...);
						end
					end
					self.user_interface[component_structure.type](self.user_interface, content);
					if component_structure.type == "combobox" and type(content.text) == "string" then
						local content_button = deep_copy(content);
						content_button.id = "submit_"..content_button.id;
						self.user_interface:button(content_button);
					end
					if content.newrow then
						self.user_interface:newrow();
					end
				end
			end, Fun.iter(self.structure_user_interface_components));
		end;
		render=function (self)
			self:rendering_update();
			if (type(self.position) ~="nil") then
				if (type(self.position.x) ~="number") then
					self.position.x=self.user_interface.bounds.x;
				elseif (self.position.x > (resolution.CurrentHorizontalResolution - self.user_interface.bounds.width)) then
					self.position.x=(resolution.CurrentHorizontalResolution - self.user_interface.bounds.width);
				end
				if (type(self.position.y) ~="number") then
					self.position.y=self.user_interface.bounds.y;
				elseif (self.position.y > (resolution.CurrentVerticalResolution - self.user_interface.bounds.height)) then
					self.position.y=(resolution.CurrentVerticalResolution - self.user_interface.bounds.height);
				end
				self.user_interface.bounds=Rectangle(self.position.x, self.position.y, self.user_interface.bounds.width, self.user_interface.bounds.height);
			end
			if not (self.first_render) then
				self.first_render=true;
			end
		end;
		update_constnets=function ()
			_ENV.constants = deep_copy(_ENV.constants_dirty)[languages_option];
		end;
		update=function (self)
			if (type(self.user_interface.data.languages)=="string") then _ENV.languages_option=self.user_interface.data.languages;languages_option=_ENV.languages_option end
			self:update_constnets();
			local bounds=Rectangle(self.user_interface.bounds.x, self.user_interface.bounds.y, self.user_interface.bounds.width, self.user_interface.bounds.height);
			self.user_interface:close();
			self:create_interface();
			self.config:onNext(bounds);
		end;
		rendering_update=function (self)
			self.user_interface:show(self.show_config);
		end;
		config_create=function (self)
			self.config=Rx.Subject.create();
			self.config:subscribe(
				function (bounds)
					self:defines_user_interface_components();
					self:rendering_update();
					if (type(bounds)=="userdata") then
						self.user_interface.bounds=Rectangle(bounds.x, bounds.y, self.user_interface.bounds.width, self.user_interface.bounds.height);
					end

				end,
				function (message)
					if (app.isUIAvailable) then
						app.alert("Error occurred in config_create > self.config:subscribe \n"..message);
					end
				end,
				function ()
					-- if (app.isUIAvailable) then
					-- end
				end);
		end;
	};
};

return {
	USER_INTERFACE=import("USER_INTERFACE");
}