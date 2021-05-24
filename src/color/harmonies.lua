
local Color=_ENV.Color;
local Fun=_ENV.Fun;
local class, public, import = _ENV.class, _ENV.public, _ENV.import;

-- local private=Pie.private;

class "HARMONIES_COLOR" {
	public {
		transformation = function(_, color, delta, weight, subtraction)
			local operation = 1;
			if type(subtraction) == "boolean" and subtraction == true then operation = -1; end
			if type(delta) == "number" then delta = { h=delta, s=delta, v=delta}; end
			if type(delta) == "table" and type(delta.h) == "nil" then delta.h = 0; end
			if type(delta) == "table" and type(delta.s) == "nil" then delta.s = 0; end
			if type(delta) == "table" and type(delta.v) == "nil" then delta.v = 0; end
			if type(weight) == "number" then weight = { h=weight, s=weight, v=weight}; end
			if type(weight) == "boolean" and weight == true then operation = -1; weight = nil; end
			if type(weight) == "nil" then weight = { h=1, s=1, v=1}; end
			if type(weight) == "table" and type(weight.h) == "nil" then weight.h = 0; end
			if type(weight) == "table" and type(weight.s) == "nil" then weight.s = 0; end
			if type(weight) == "table" and type(weight.v) == "nil" then weight.v = 0; end
			local s =(color.saturation + ((weight.s * delta.s) * operation));
			local v =(color.hsvValue + ((weight.v * delta.v) * operation));
			if s > 1 then s = 1 - s%1; end
			if v > 1 then v = 1 - v%1; end
			return Color({
				h=(color.hsvHue + ((weight.h * delta.h) * operation))%360,
				s=s,
				v=v
			});
		end;
		pattern_palette = function (self, color, angle, delta, callback, palette, initial_color, index)
			if type(palette) == "nil" then palette = Fun.iter({}) end
			if type(callback) == "nil" then callback = function () return true end end
			if type(initial_color) == "nil" then initial_color = color end
			if type(index) == "nil" then index = 1 end
			if index <= math.floor((360/angle)+0.5) then
				local new_color = self:transformation(color, {h=angle});
				local current_color = self:transformation(color, {h=angle});
				if callback(self, index, current_color, initial_color) then
					local color1 = self:transformation(current_color, delta);
					local color2 = self:transformation(current_color, delta, true);
					return self:pattern_palette(new_color, angle, delta, callback, palette:chain({color1, current_color, color2}), initial_color, index+1);
				else
					return self:pattern_palette(new_color, angle, delta, callback, palette, initial_color, index+1);
				end
			else
				local outcome = {};
				palette:each(function (value) outcome[#outcome+1] = value; end);
				return outcome, palette;
			end
		end;
		palette_tones = function(self, color, delta, deep, palette, index)
			if type(index) == "nil" then if deep > 0 then index = deep * -1 else index = deep end end
			if type(palette) == "nil" then palette = Fun.iter({}) end
			if index <= deep then
				local new_color = self:transformation(color, delta, index);
				return self:palette_tones(color, delta, deep, palette:chain({new_color}), index+1);
			else
				local outcome = {};
				palette:each(function (value) outcome[#outcome+1] = value; end);
				return outcome, palette;
			end
		end;
		analogs = function (self, color)
			return self:pattern_palette(color, 15, {s = 0.06, v = -0.09}, function (_, index)
				return index == 1 or index == 2 or index == 24 or index == 23 or index == 22;
			end);
		end;
		complementary = function (self, color)
			return self:pattern_palette(color, 180, {s = 0.06, v = -0.09});
		end;
		split_complementary = function (self, color)
			return self:pattern_palette(color, 30, {s = 0.06, v = -0.09}, function (_, index)
				return index == 5 or index == 7 or index == 12;
			end);
		end;
		compounds = function (self, color)
			return self:pattern_palette(color, 5, {s = 0.24, v = -0.36}, function (_, index, current_color)
				if index == 33 then
					current_color.hsvValue = current_color.hsvValue * 0.6;
					current_color.saturation = current_color.saturation * 0.9;
				end
				return index == 4 or index == 36 or index == 32 or index == 72;
			end);
		end;
		squares = function (self, color)
			return self:pattern_palette(color, 90, {s = 0.06, v = -0.09});
		end;
		complementary_doubles = function (self, color)
			return self:pattern_palette(color, 30, {s = 0.06, v = -0.09}, function (_, index)
				return index == 1 or index == 5 or index == 7 or index == 11 or index == 12;
			end);
		end;
		monochromaticos = function (self, color)
			return self:palette_tones(color, {s = 0.12}, 5);
		end;
		shades = function (self, color)
			return self:palette_tones(color, {s = 0.06, v = -0.09}, 5);
		end;
		tones = function (self, color)
			return self:palette_tones(color, {v = -0.06}, 5);
		end;
		triad = function (self, color)
			return self:pattern_palette(color, 120, {s = 0.06, v = -0.09});
		end;
		complementary_triad = function (self, color)
			return self:pattern_palette(color, 15, {s = 0.06, v = -0.09}, function (_, index)
				return index == 9 or index == 15 or index == 24;
			end);
		end;
	};
};

return {
	HARMONIES_COLOR=import("HARMONIES_COLOR");
};