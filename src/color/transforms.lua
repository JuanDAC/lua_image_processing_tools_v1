
local Color=_ENV.Color;
local Fun=_ENV.Fun;
local class, public, import = _ENV.class, _ENV.public, _ENV.import;

-- local private=Pie.private;
class "TRANSFORMS" {
	public {
		gray_scale=function(_, color) return Color({
			h=color.hsvHue,
			s=0,
			v=color.hsvValue
		}) end;
		random_color=function(_) return Color({
			h=math.floor((math.random() * 360) + 0.5),
			s=math.random(),
			v=math.random(),
		}) end;
		blend_colors=function(_, color_one, color_two, balance)
			local porcentage = balance * 0.01;
			local h, s, v = (color_one.hsvHue * (1-porcentage))+(color_two.hsvHue * porcentage), (color_one.saturation * (1-porcentage))+(color_two.saturation * porcentage), (color_one.hsvValue * (1-porcentage))+(color_two.hsvValue * porcentage);
			return Color({ h=h, s=s, v=v })
		end;
		gradient_generator=function(self, color_one, color_two, number_colors) if number_colors >= 3 then
			local outcome={color_one,};
			Fun.range(number_colors):each(function (index) outcome[#outcome+1]=self:blend_colors(color_one, color_two, (index)*(100/number_colors)) end);
			return outcome;
		end end;
		contrast = function (_, color_one, color_two)
			local lum1 = (color_one.lightness);
			local lum2 = (color_two.lightness);
			local brightest = math.max(lum1, lum2);
			local darkest = math.min(lum1, lum2);
			local contrast = math.floor((((brightest + 0.05) / (darkest + 0.05))*100)+0.5)/100;
			local contrast_text = contrast > 2.1;
			local contrast_text_best = contrast > 3;
			local contrast_text_color_blind = contrast > 4.5;
			return contrast, { text=contrast_text; text_best=contrast_text_best; color_blind=contrast_text_color_blind; };
		end;
	}
}

return {
	TRANSFORMS=import("TRANSFORMS");
};
