
-- local Color=_ENV.Color;
-- local Fun=_ENV.Fun;
-- local app=_ENV.app;
-- local ColorMode=_ENV.ColorMode;
-- local Image=_ENV.Image;
-- local Point=_ENV.Point;
local class, public, import = _ENV.class, _ENV.private, _ENV.import;


-- local private=Pie.private;
class "TRANSFORMATIONS" {
	public {
		radians=function(_, props)
			return (props.angle * math.pi)/180;
		end;
		rotate=function(self, angle) return function(props)
			return {
				x=((props.x * math.cos(self:radians(angle))) - (props.y * math.sin(self:radians(angle))));
				y=((props.y * math.cos(self:radians(angle))) + (props.x * math.sin(self:radians(angle))));
			};
		end end;
	}
}


return {
	TRANSFORMATIONS=import("TRANSFORMATIONS");
};
