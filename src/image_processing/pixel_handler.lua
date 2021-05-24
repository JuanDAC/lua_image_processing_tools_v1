local app=_ENV.app;
local class, public, import = _ENV.class, _ENV.public, _ENV.import;
local rgbaR, rgbaG, rgbaB, rgbaA, rgba = app.pixelColor.rgbaR, app.pixelColor.rgbaG, app.pixelColor.rgbaB, app.pixelColor.rgbaA, app.pixelColor.rgba;
local floor, clamp, min, max = math.floor, math.clamp, math.min, math.max;

class "PIXEL_HANDLER" {
	public {
		negative_value=function(_, value) return 255 - value end;
		black_white_value=function() return function(range) return function(value)
			local digital=0;
			if value>range then digital=255 end
			return digital;
		end end end;
		without=function()
			return (function(...) return ... end);
		end;
		grayscale=function() return function (pixel)
			local gray, alfa = floor((rgbaR(pixel) + rgbaG(pixel) + rgbaB(pixel)) / 3), rgbaA(pixel);
			return rgba(gray, gray, gray, alfa);
		end end;
		maximum_gray=function() return function(pixel)
			local gray, alfa = max(rgbaR(pixel), rgbaG(pixel), rgbaB(pixel)), rgbaA(pixel);
			return rgba(gray, gray, gray, alfa);
		end end;
		minimum_gray=function() return function(pixel)
			local gray, alfa = min(rgbaR(pixel), rgbaG(pixel), rgbaB(pixel)), rgbaA(pixel);
			return rgba(gray, gray, gray, alfa);
		end end;
		negative_gray=function(self) return function(pixel)
			local gray, alfa = self:negative_value(floor((rgbaR(pixel) + rgbaG(pixel) + rgbaB(pixel)) / 3)), rgbaA(pixel);
			return rgba(gray, gray, gray, alfa);
		end end;
		negative_color=function(self) return function(pixel)
			local r, g, b, a = rgbaR(pixel), rgbaG(pixel), rgbaB(pixel), rgbaA(pixel);
			return rgba(
				self:negative_value(r),
				self:negative_value(g),
				self:negative_value(b),
				a
		) end end;
		get_values_pixel=function () return function (pixel)
			return rgbaR(pixel), rgbaG(pixel), rgbaB(pixel), rgbaA(pixel);
		end end;
		black_white=function(self) return function(range) return function(pixel)
			local digital, alfa = self:black_white_value()(range)(floor((rgbaR(pixel) + rgbaG(pixel) + rgbaB(pixel)) / 3)), rgbaA(pixel);
			return rgba(digital, digital, digital, alfa);
		end end end;
		colorize=function() return function(color)
			local percentage_of_red, percentage_of_green, percentage_of_blue = color.red/255, color.green/255, color.blue/255;
			return function(handler_pixel) return function(pixel)
				local new_pixel = handler_pixel(pixel);
				local color_of_red = clamp(0, rgbaR(new_pixel) * percentage_of_red , 255);
				local color_of_green = clamp(0, rgbaG(new_pixel) * percentage_of_green , 255);
				local color_of_blue = clamp(0, rgbaB(new_pixel) * percentage_of_blue , 255);
				return rgba(color_of_red, color_of_green, color_of_blue, rgbaA(new_pixel));
			end end
		end end;
		-- colorize_g=function(self) return function(color) return function(pixel)
		-- 	local percentage_of_red, percentage_of_green, percentage_of_blue = color.red/255, color.green/255, color.blue/255;
		-- 	local new_pixel = self:minimum_gray()(pixel);
		-- 	local color_of_red = max(min(rgbaR(new_pixel) * percentage_of_red , 255), 0);
		-- 	local color_of_green = max(min(rgbaG(new_pixel) * percentage_of_green , 255), 0);
		-- 	local color_of_blue = max(min(rgbaB(new_pixel) * percentage_of_blue , 255), 0);
		-- 	return rgba(color_of_red, color_of_green, color_of_blue, rgbaA(new_pixel));
		-- end end end;
		brightness = function () return function (brightness_) return function (pixel)
			local brightness = brightness_ * 0.01;
			local color_of_red = clamp(0, rgbaR(pixel) * brightness , 255);
			local color_of_green = clamp(0, rgbaG(pixel) * brightness , 255);
			local color_of_blue = clamp(0, rgbaB(pixel) * brightness , 255);
			return rgba(color_of_red, color_of_green, color_of_blue, rgbaA(pixel));
		end end end;
	}
};

return {
	PIXEL_HANDLER=import("PIXEL_HANDLER");
};
