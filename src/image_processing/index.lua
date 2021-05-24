
-- local Color=_ENV.Color;
local Fun=_ENV.Fun;
-- local app=_ENV.app;
local ColorMode=_ENV.ColorMode;
local Image=_ENV.Image;
local Point=_ENV.Point;
local class, public, import = _ENV.class, _ENV.public, _ENV.import;

-- local private=Pie.private;
class "IMAGE_PROCESSING" {
	public {
		each_image_wrapper = function (self, wrapper, property, callback) -- property > "layers", "cels"
			if type(wrapper[property]) == "nil" or #wrapper[property] <= 0 then
				return nil
			end
			local current_iter = Fun.iter({table.unpack(wrapper[property])});
			local length = Fun.length(current_iter);
			current_iter:enumerate():each(function (index, item)
				if type(item) ~= "nil" then
					if property=="layers" and item.isGroup then
						item.isVisible = true;
						self:each_image_wrapper(item, property, callback);
					end;
					if (property=="layers" and item.isImage) or (property=="cels" and item.image) then callback(index, item, length) end;
				end;
			end);
		end;
		image_handler = function (_, cel, pixel_handler, transform)
			-- app.alert("hi image handler ja "..type(pixel_handler));
			local image = Image(cel.image.width, cel.image.height, ColorMode.RGB);
			if type(transform) == "nil" then
				transform=(function (x, y) return {x=x, y=y} end);
			end;
			Fun.range(0, cel.image.width-1):each(function (x)
				Fun.range(0, cel.image.height-1):each(function (y)
					local pixel=cel.image:getPixel(x, y);
					local position=transform(x, y);
					local new_pixel=pixel_handler(pixel, cel);
					image:drawPixel(position.x, position.y, new_pixel);
				end)
			end);
			local position = transform(cel.position);
			return image, Point(position.x, position.y);
		end;
		image_handler_values_pixel = function (_, cel, pixel_handler)
			-- app.alert(type(pixel_handler));
			local r_value, g_value, b_value, a_value, current_total = 0, 0, 0, 0, 0;
			Fun.range(0, cel.image.width-1):each(function (x) Fun.range(0, cel.image.height-1):each(function (y)
				local pixel=cel.image:getPixel(x, y);
				local current_value_r, current_value_g, current_value_b, current_value_a=pixel_handler(pixel);
				r_value, g_value, b_value, a_value = r_value + current_value_r, g_value + current_value_g, b_value + current_value_b, a_value + current_value_a;
				current_total = current_total + 1;
			end) end);
			return r_value, g_value, b_value, a_value, current_total;
		end;
	}
}

return {
	IMAGE_PROCESSING=import("IMAGE_PROCESSING");
};