local import_module=_ENV.import_module;
local Pie=_ENV.Pie;
local Fun=_ENV.Fun;
-- local interface=Pie.interface;
-- local implements=Pie.implements;
-- local abstract_function=Pie.abstract_function;
local class=Pie.class;
local public=Pie.public;
-- local private=Pie.private;
local import=Pie.import;
-- local RGB_MAX_VALUA = 255;
local matrix_filters = import_module("color.filters");

-- local is_matrix_operable = function (matrix, cb, ...)
-- 	local matrix_operable = true;
-- 	local args = Fun.iter({...});
-- 	Fun.iter(matrix):each(function (matrix_deep)
-- 		if (type(cb) == "function") then matrix_operable = matrix_operable and cb("column", matrix_deep, args, Fun.len(args)); end
-- 		local i=1;
-- 		Fun.iter(matrix_deep):each(function (value)
-- 			matrix_operable = matrix_operable and type(value) == "number";
-- 			if (type(cb) == "function") then matrix_operable = matrix_operable and cb("cell", value, args, Fun.len(args)); end
-- 			i=i+1;
-- 		end);
-- 	end);
-- 	return matrix_operable;
-- end
-- local matrix_multiplication_by_scalar = function (matrix, scalar)
-- 	local matrix_iter = Fun.iter(matrix);
-- 	if type(scalar) ~= "number" and not is_matrix_operable(matrix) then return false; end;
-- 	return matrix_iter:map(function (matrix_deep)
-- 		return Fun.iter(matrix_deep):map(function (value)
-- 			return value * scalar;
-- 		end);
-- 	end);
-- end

local matrix_multiplication_by_vectors = function (matrix, vector)
	local matrix_iter = Fun.iter(matrix);
	local vector_iter = Fun.iter(vector);
	local matrix_operable = true;
	matrix_iter:each(function (matrix_deep)
		matrix_operable = matrix_operable and Fun.len(matrix_deep) == Fun.len(vector);
		local i=1;
		Fun.iter(matrix_deep):each(function (value)
			matrix_operable = matrix_operable and type(value) == "number" and type(vector_iter:nth(i)) == "number";
			i=i+1;
		end);
	end);
	if not matrix_operable then return false; end;
	return matrix_iter:map(function (matrix_deep)
		local i=1;
		local matrix_deep_iter = Fun.iter(matrix_deep);
		return vector_iter:reduce(function (acc, multiplier)
			local multiplying = matrix_deep_iter:nth(i);
			local product = multiplier * multiplying;
			i=i+1;
			return acc+product;
		end, 0);
	end);
end


class "COLOR" {
	public {
		RGB_TO_LAB = function (_, r, g, b)
			if math.max(r,g,b) then
				r = r/255;
				g = g/255;
				b = b/255;
			end
			local X = ((0.412453 * r) + (0.357580 * g) + (0.180423 * b)) / 0.950456;
			local Y = ((0.212671 * r) + (0.715160 * g) + (0.072169 * b));
			local Z = ((0.019334 * r) + (0.119193 * g) + (0.950227 * b)) / 1.088754;
			local T = 0.008856;
			local fX, Y3, fY, fZ, L;
			if X > T then
				fX = math.pow(X, 1/3)
			else
				fX = 7.787 * X + 16/116;
			end
			if Y > T then
				Y3 = math.pow(Y, 1/3);
				fY = Y3;
				L  = 116 * Y3 - 16.0;
			else
				fY = 7.787 * Y + 16/116;
				L  = 903.3 * Y;
			end
			if Z > T then
				fZ = math.pow(Z, 1/3)
			else
				fZ = 7.787 * Z + 16/116
			end
			local a = 500 * (fX - fY);
			b = 200 * (fY - fZ);
			return L, a, b;
		end;
		color_distance = function (self, r1, g1, b1, r2, g2, b2)
			local l1, a1, l2, a2;
			if type(r1) == "table" and type(g1) == "table" and type(b1) == "nil" and type(r2)  == "nil" and type(g2)  == "nil" and type(b2) == "nil" then
				l1, a1, b1 = self:RGB2LAB(r1);
				l2, a2, b2 = self:RGB2LAB(g1);
			else
				l1, a1, b1 = self:RGB2LAB(r1,g1,b1);
				l2, a2, b2 = self:RGB2LAB(r2,g2,b2);
			end
			local dl = l1-l2;
			local C1 = math.sqrt(a1*a1 + b1*b1);
			local C2 = math.sqrt(a2*a2 + b2*b2);
			local dC = C1 - C2;
			local da = a1-a2;
			local db = b1-b2;
			local dH = math.sqrt(math.max(0, da*da + db*db - dC*dC));
			local Kl = 1;
			local K1 = 0.045;
			local K2 = 0.015;
			local s1 = dl/Kl;
			local s2 = dC/(1. + K1 * C1);
			local s3 = dH/(1. + K2 * C1);
			return math.sqrt(s1*s1 + s2*s2 + s3*s3);
		end;
		get_color = function(self, col)
			if type(col) == "string" then
				return self:parseHexColor(col)
			else
				return col
			end
		end;
		HSV_TO_RGB = function(_, h, s, v)
			local HsubI = math.abs((h/60)%6);
			local f = ((h/60)%6) - HsubI;
			local p, q, t = (v*(1-s))*255, (v*(1 - f*s))*255, (v*(1 - (1 - f)*s))*255;
			v = v*255;
			if (HsubI == 0) then return v, t, p end;
			if (HsubI == 1) then return q, v, p end;
			if (HsubI == 2) then return p, v, t end;
			if (HsubI == 3) then return p, q, v end;
			if (HsubI == 4) then return t, p, v end;
			if (HsubI == 5) then return v, p, q end;
		end;
		RGB_TO_HSV = function(_, r, g, b)
			local min = math.min(r, g, b);
			local max = math.max(r, g, b);
			local delta = max - min;
			local h, s, v;
			v = max;
			if delta < 0.00001 then
				s = 0;
				h = 0;
				return h, s, v;
			end
			if max > 0 then
				s = (delta / max);
			else
				s = 0;
				h = 0;
				return h, s, v;
			end
			if r > max then
				h = (g - b) / delta;
			else
				if g >= max then
					h = 2 + (b - r) / delta;
				else
					h = 4 + (r - g) / delta;
				end
			end
			h = h * 60;
			if(h < 0.0 ) then
				h = h + 360;
			end
			return h, s, v;
		end;

		RGB_2_HSV = function(_, r, g, b)
			local min = math.min(r, g, b);
			local max = math.max(r, g, b);
			local h, v, s;
			v = max;
			if v == 0 then
					h = 0;
					s = 0;
					return h, s, v;
			end
			s = (255 * (max - min)) / v;
			if s == 0 then
				h = 0;
				return h, s, v;
			end
			if max == r then
					h = 0 + 43 * (g - b) / (max - min);
			elseif max == g then
					h = 85 + 43 * (b - r) / (max - min);
			else
					h = 171 + 43 * (r - g) / (max - min);
			end
			return h, s, v;
		end;
		RGB_TO_HSL = function (_, r, g, b)
			r, g, b = r/255, g/255, b/255;
			local v, m, vm, r2, g2, b2;
			local h, s, l = 0, 0, 0;
			v = math.max(math.max(r, g), b);
			m = math.min(math.min(r, g), b);
			l = (m + v) / 2;
			if (l <= 0) then
				return h, s, l;
			end
			vm = v - m;
			s = vm;
			if (s > 0) then
				if (l <= 0.5) then
					s = s / (v + m );
				else
					s = s / (2.0 - v - m);
				end
			else
				return h, s, l;
			end
			r2 = (v - r) / vm;
			g2 = (v - g) / vm;
			b2 = (v - b) / vm;
			if (r == v) then
				if g == m then
					h = 5 + b2;
				else
					h = 1 - g2;
				end
			elseif (b == m) then
				if g == m then
					h = 1 + r2;
				else
					h = 3 - b2;
				end
			else
				if r == m then
					h = 3 + g2;
				else
					h = 5 - r2;
				end
			end
			h = h / 6.0;
			return h, s, l;
		end;
		HSL_TO_RGB = function (_, h, sl, l)
			local r, g, b, v = l, l, l, (function () if (l <= 0.5) then return (l * (1.0 + sl)) else return (l + sl - (l * sl)) end end)();
			if v > 0 then
				local m;
				local sv;
				local sextant;
				local fract, vsf, mid1, mid2;
				m = l + l - v;
				sv = (v - m ) / v;
				h = h * 6.0;
				sextant = math.floor(h);
				fract = h - sextant;
				vsf = v * sv * fract;
				mid1 = m + vsf;
				mid2 = v - vsf;
				if (sextant == 0) then r, g, b = v, mid1, m;
					elseif (sextant == 1) then r, g, b = mid2, v, m;
					elseif (sextant == 2) then r, g, b = m, v, mid1;
					elseif (sextant == 3) then r, g, b = m, mid2, v;
					elseif (sextant == 4) then r, g, b = mid1, m, v;
					elseif (sextant == 4) then r, g, b = v, m, mid2;
				end
			end
			r = r * 255;
			g = g * 255;
			b = b * 255;
			return r, g, b;
		end;
		RGB_TO_YUV = function (_, r, g, b)
			r, g, b = r/255, g/255, b/255;
			local y, u, v = 16 + ((65.738*r)/256) + ((129.057*g)/256) + ((25.064*b)/256), 128 - ((37.945*r)/256) - ((74.494*g)/256) + ((112.439*b)/256), 128 + ((112.439*r)/256) - ((94.154*g)/256) - ((18.285*b)/256);
			return y, u, v;
		end;
		YUV_TO_RGB = function (_, y, u, v)
			local r, g, b = y + (1.14*v), y - (0.396*u) - (0.581*v), y + (2.029*u);
			return r*255, g*255, b*255;
		end;
		RGB_TO_CMYK = function (_, r, g, b)
			local c, m, y = 255 - r, 255 - g, 255 - b;
			b = math.min(c, m, y);
			c = math.round((c - b) / (255 - b));
			m = math.round((m - b) / (255 - b));
			y = math.round((y - b) / (255 - b));
			local k = math.round(b / 255);
			return c, m, y, k;
		end;
		CMYK_TO_RGB = function (_, c, m, y, k)
			local r, g, b = 255 - math.round(2.55 * (c + k)), 255 - math.round(2.55 * (m + k)), 255 - math.round(2.55 * (y + k));
			r = math.max(r, 0);
			g = math.max(g, 0);
			b = math.max(b, 0);
			return r, g, b;
		end;
		RGB_TO_RGBA = function (_, r, g, b)
			local min = math.min(r, g, b);
			local a = (255 - min) / 255;
			r = math.round((r - min) / a);
			g = math.round((g - min) / a);
			b = math.round((b - min) / a);
			a = math.round(a);
			return r, g, b, a;
		end;
		RGB_TO_HEX = function (_, r, g, b)
			return "#"..tostring(r, 16)..tostring(g, 16)..tostring(b, 16);
		end;
		HEX_TO_RGB = function (_, hex)
			if Fun.len(hex) ~= 4 and Fun.len(hex) ~= 7 and not Fun.iter(hex):head() == "#" then
					return 0, 0, 0;
			end
			local r, g, b;
			if Fun.len(hex) == 4 then
					r = Fun.iter(hex):nth(2);
					r = r..r;
					g = Fun.iter(hex):nth(3);
					g = g..g;
					b = Fun.iter(hex):nth(4);
					b = b..b;
			else
					r = Fun.iter(hex):nth(2)..Fun.iter(hex):nth(3);
					g = Fun.iter(hex):nth(4)..Fun.iter(hex):nth(5);
					b = Fun.iter(hex):nth(6)..Fun.iter(hex):nth(7);
			end
			return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16);
		end;
		HEX_TO_GRAY = function (_, r, g, b)
			local gray = (r + g + b) / 3;
			return gray, gray, gray;
		end;
		RGB_TO_CIE = function (_, r, g, b)
			local x, y, z = (r/(r + g + b)), (g/(r + g + b)), (b/(r + g + b));
			return x, y, z;
		end;
		brightness = function (_, r, g, b)
			local a = Fun.iter({r, g, b}):map(function (value)
				value = value / 255;
				if value <= 0.03928 then
					return value / 12.92;
				else
					return math.pow( (value + 0.055) / 1.055, 2.4 );
				end
			end);
			return a:nth(1) * 0.2126 + a:nth(2) * 0.7152 + a:nth(3) * 0.0722;
		end;
		brightness_deep = function (_, r, g, b)
			return math.sqrt(math.pow(0.299*r) + math.pow(0.587*g) + math.pow(0.114*b));
		end;
		contrast = function (self, r1, g1, b1, r2, g2, b2)
			local lum1 = self:brightness(r1, g1, b1);
			local lum2 = self:brightness(r2, g2, b2);
			local brightest = math.max(lum1, lum2);
			local darkest = math.min(lum1, lum2);
			return (brightest + 0.05) / (darkest + 0.05);
		end;
		invert = function (_, r, g, b)
			return math.round(255-r), math.round(255-g), math.round(255-b);
		end;
		hue = function(_, r, g, b)
			local min = math.min(math.min(r, g), b);
			local max = math.max(math.max(r, g), b);
			local hue = 0;
			if (min == max) then return hue; end;
			if (max == r) then
					hue = (g - b) / (max - min);
			elseif (max == g) then
					hue = 2 + (b - r) / (max - min);
			else
					hue = 4 + (r - g) / (max - min);
			end
			hue = hue * 60;
			if (hue < 0) then hue = hue + 360; end
			return math.round(hue);
		end;
		gamma = function (_, r, g, b, gamma)
			return math.pow(r, 1/gamma), math.pow(g, 1/gamma), math.pow(b, 1/gamma)
		end;
		sepia = function (_, r, g, b)
			local result = matrix_multiplication_by_vectors(matrix_filters.sepia, {r, g, b});
			r, g, b = math.max(math.min(result:nth(1), 255), 0), math.max(math.min(result:nth(2), 255), 0), math.max(math.min(result:nth(3), 255), 0);
			return r, g, b;
		end
	}
};

_ENV.Color = import("COLOR");
