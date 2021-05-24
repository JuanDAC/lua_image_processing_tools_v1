-- local D_type=_ENV.D_type;
local app, import_module, TEXTS, deep_copy=_ENV.app, _ENV.import_module, _ENV.TEXTS, _ENV.deep_copy;
local class, public, import = _ENV.class, _ENV.public,  _ENV.import;

-- local Dialog = _ENV.Dialog;
-- local MouseButton=_ENV.MouseButton;
-- local return_true = _ENV.return_true;

local image_processing=import_module("image_processing").IMAGE_PROCESSING();
local pixel_handler=import_module("image_processing.pixel").PIXEL_HANDLER();
-- local
do
	local current_filter = nil;
	local actions_after_apply = nil;
	local actions_before_apply = nil;
	class "ON_ClICK_FUNCTIONS_FILTER" {
		public {
			-- config
			filter_applicator = function (self) return function (config)
			local selection = app.activeSprite;
			if (selection) then
				local newEmptyFrame = selection:newEmptyFrame();
				-- local first, current_item, max = true, 1, 0;
				if type(actions_before_apply) == "function" then
					if not actions_before_apply(config.user_interface) then
						app.alert("They talked data");
						return ;
					end
					actions_before_apply = nil;
				end
				app.alert(TEXTS.loader.text[_ENV.languages_option]);
				image_processing:each_image_wrapper(selection, "layers", function (_, layer, _) -- (_, layer, length_layer)
					image_processing:each_image_wrapper(layer, "cels", function (_, cel, _) --(_, cel, length_cel)
						-- if first then
						-- 	max=length_layer*length_cel;
						-- 	first=false;
						-- end
						-- if max > 30 and current_item == math.floor(max/2) then app.alert(TEXTS.loader.text[_ENV.languages_option]) end
						local image, point = image_processing:image_handler(cel, current_filter);
						selection:newCel(layer, newEmptyFrame, image, point);
						-- current_item = current_item + 1;
					end);
				end);
				self:active_apply_filter(config, false)
				if type(actions_after_apply) == "function" then
					actions_after_apply(config.user_interface);
					actions_after_apply = nil;
				end
				app.refresh();
			end;
		end end;
		filter_counting = function (self)
			-- config
			local selection = app.activeSprite;
			if (selection) then
				local current_counting = 0;
				local current_counting_values = 0;
				image_processing:each_image_wrapper(selection, "layers", function (_, layer)
					image_processing:each_image_wrapper(layer, "cels", function (_, cel)
						local r_value, g_value, b_value, _, t_value = image_processing:image_handler_values_pixel(cel, pixel_handler:get_values_pixel());
						app.alert(type(g_value))
						current_counting = current_counting + t_value;
						current_counting_values = current_counting_values + r_value + g_value + b_value;
					end);
				end);
				self.current_average = current_counting_values / (current_counting * 3);
			end;
		end;
		active_apply_filter = function (_, config, visible)
			config.user_interface:modify{
				id="apply_filter";
				visible=visible;
			};
		end;
		combobox_type_filter_colorize=function (self) return function (map, config)
			-- [default]
			if (map.default==config.data.combobox_type_filter_colorize) then
				current_filter.handler_pixel=pixel_handler:grayscale();
				self:active_apply_filter(config, true);
			elseif (map.maximum==config.data.combobox_type_filter_colorize) then
			-- [maximum]
				current_filter.handler_pixel=pixel_handler:maximum_gray();
				self:active_apply_filter(config, true);
			elseif (map.minimum==config.data.combobox_type_filter_colorize) then
			-- [minimum]
				current_filter.handler_pixel=pixel_handler:minimum_gray();
				self:active_apply_filter(config, true);
			end
		end end;
		combobox_filters=function (self) return function (map, config)
			-- [grayscale]
			if (map.grayscale==config.data.combobox_filters) then
				current_filter=pixel_handler:grayscale();
				self:active_apply_filter(config, true)
			elseif (map.maximum_gray==config.data.combobox_filters) then
			-- [maximum_gray]
				current_filter=pixel_handler:maximum_gray();
				self:active_apply_filter(config, true)
			elseif (map.minimal_gray==config.data.combobox_filters) then
			-- [minimal_gray]
				current_filter=pixel_handler:minimum_gray();
				self:active_apply_filter(config, true)
			elseif (map.negative==config.data.combobox_filters) then
			-- [negative]
				current_filter=pixel_handler:negative_color();
				self:active_apply_filter(config, true)
			elseif (map.black_and_white==config.data.combobox_filters) then
			-- [black_and_white] -> range
				-- self:filter_counting();
				current_filter=pixel_handler:black_white();
				self:active_apply_filter(config, true)
				config.user_interface:modify{
					id="balance_black_and_white";
					visible=true;
				};
				actions_before_apply = function ()
					local balance = tonumber(config.user_interface.data.balance_black_and_white);
					current_filter = current_filter(balance);
					return true;
				end
				actions_after_apply = function ()
					config.user_interface:modify{
						id="balance_black_and_white";
						visible=false;
					};
				end;
			elseif (map.colorize==config.data.combobox_filters) then
				current_filter={
					colorize = pixel_handler:colorize();
				};
				config.user_interface:modify{
					id="color_picker";
					visible=true;
				}:modify{
					id="submit_color_foreground_picker";
					visible=true;
				}:modify{
					id="submit_color_background_picker";
					visible=true;
				}:modify{
					id="submit_combobox_type_filter_colorize";
					visible=true;
				}:modify{
					id="combobox_type_filter_colorize";
					visible=true;
				};
				actions_before_apply = function ()
					app.refresh();
					local color = config.user_interface.data.color_picker;
					if type(color)=="userdata" then
						local options = deep_copy(current_filter);
						current_filter = options.colorize(color)(options.handler_pixel);
						return true;
					else
						return false;
					end
				end;
				actions_after_apply = function ()
					config.user_interface:modify{
						id="color_picker";
						visible=false;
					}:modify{
						id="submit_color_foreground_picker";
						visible=false;
					}:modify{
						id="submit_color_background_picker";
						visible=false;
					}:modify{
						id="submit_combobox_type_filter_colorize";
						visible=false;
					}:modify{
						id="combobox_type_filter_colorize";
						visible=false;
					};
				end;
			elseif (map.brightness==config.data.combobox_filters) then
				self:active_apply_filter(config, true)
				current_filter= pixel_handler:brightness();
				config.user_interface:modify{
					id="label_brightness";
					visible=true;
				}:modify{
					id="slider_brightness";
					visible=true;
				}
				actions_before_apply = function ()
					app.refresh();
					local range = tonumber(config.user_interface.data.slider_brightness) + 100;
					if type(range)=="number" then
						current_filter = current_filter(range);
						return true;
					else
						return false;
					end
				end
				actions_after_apply = function ()
					config.user_interface:modify{
						id="label_brightness";
						visible=false;
					}:modify{
						id="slider_brightness";
						visible=false;
					}
				end;
			end;
		end end;
		-- TODO
	-- elseif (map.transposed==config.data.combobox_filters) then
	-- current_filter=pixel_handler:grayscale();
	-- elseif (map.color_component==config.data.combobox_filters) then
	-- 	-- current_filter=pixel_handler:grayscale();
	-- elseif (map.chromatic_aberration==config.data.combobox_filters) then
	-- 	-- current_filter=pixel_handler:grayscale();
	-- elseif (map.squares==config.data.combobox_filters) then
	-- 	-- current_filter=pixel_handler:grayscale();
	-- elseif (map.gamma==config.data.combobox_filters) then
	-- 	-- current_filter=pixel_handler:grayscale();
	-- elseif (map.colors_gradient==config.data.combobox_filters) then
	-- 	-- current_filter=pixel_handler:grayscale();
	-- 	-- current_filter=pixel_handler:grayscale();
	-- elseif (map.contrast==config.data.combobox_filters) then
	-- 	-- current_filter=pixel_handler:grayscale();
	-- elseif (map.filp_horizontal==config.data.combobox_filters) then
	-- 	-- current_filter=pixel_handler:grayscale();
	-- elseif (map.noise==config.data.combobox_filters) then
	-- 	-- current_filter=pixel_handler:grayscale();
	-- elseif (map.mosaic==config.data.combobox_filters) then
	-- 	-- current_filter=pixel_handler:grayscale();
	-- elseif (map.transparency==config.data.combobox_filters) then
	};
};
end
local onClick_functions = import("ON_ClICK_FUNCTIONS_FILTER")();

return function (global_functions)
	return {
		title=TEXTS.filters.title;
		onclose=(function () end);
		structure={
			{
				type="separator";
				content={
					id="separator_color";
					text=TEXTS.filters.separator_filter.text;
				};
			},
			{
				type="combobox";
				content={
					id="combobox_filters";
					-- visible=false;
					option="";
					options=TEXTS.filters.combobox_filters.options;
					text=TEXTS.filters.combobox_filters.text;
					onclick=onClick_functions:combobox_filters();
				};
			},
			{
				type="slider";
				content={
					id="balance_black_and_white";
					selected=false;
					visible=false;
					min=0;
					max=255;
					value=127;
				};
			},
			{
				type="color";
				content={
					id="color_picker";
					visible=false;
					color=app.fgColor;
					newrow=true;
				};
			},
			{
				type="button";
				content={
					id="submit_color_foreground_picker";
					text=TEXTS.color.submit_color_foreground_picker.text;
					selected=false;
					newrow=false;
					visible=false;
					onclick=global_functions.set_color(global_functions.set_color_fg)("color_picker");
				};
			},
			{
				type="button";
				content={
					id="submit_color_background_picker";
					text=TEXTS.color.submit_color_background_picker.text;
					selected=false;
					newrow=true;
					visible=false;
					onclick=global_functions.set_color(global_functions.set_color_bg)("color_picker");
				};
			},
			{
				type="combobox";
				content={
					id="combobox_type_filter_colorize";
					-- visible=false;
					option="";
					options=TEXTS.filters.combobox_type_filter_colorize.options;
					text=TEXTS.filters.combobox_type_filter_colorize.text;
					onclick=onClick_functions:combobox_type_filter_colorize();
					visible=false;
				};
			},
			{
				type="label";
				content={
					id="label_brightness";
					text=TEXTS.color.balance_blend_colors.text;
					selected=false;
					newrow=false;
					visible=false;
				};
			},
			{
				type="slider";
				content={
					id="slider_brightness";
					selected=false;
					visible=false;
					min=-100;
					max=100;
					value=0;
				};
			},
			{
				type="button";
				content={
					id="apply_filter";
					text=TEXTS.filters.apply_filter.text;
					onclick=onClick_functions:filter_applicator();
					newrow=false;
					visible=false;
				};
			},
		};
	};
end
