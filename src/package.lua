return {
	name="";
	version="1.0.0";
	description="";
	main="index.js",
	directories= {
		["test"]="test"
	};
	keywords={
		"color";
		"image processing";
		"image";
	},
	repository={
		type="git";
		url="";
	},
	bugs={
    ["url"]="https://github.com/Easybuoy/package.json-mastery/issues";
	};
	exclude={
		"server/app.js";
		"server/config/";
		"server/build";
	};
	engines={
    ["lua"]=">= 5.1";
    ["luarocks"]=">= 2";
    ["aseprite"]=">= 1";
  };
	author="";
	homepage="";
	license="MIT";
	scripts={
		["lualint"]="echo \"Error: no test specified\" && exit 1";
		["lualint:fix"]="echo \"Error: no test specified\" && exit 1";
		["validate:dev"]="echo \"Error: no test specified\" && exit 1";
		["validate"]="echo \"Error: no test specified\" && exit 1";
		["test"]="echo \"Error: no test specified\" && exit 1";
		["aseprite:test"]="echo \"Error: no test specified\" && exit 1";
		["aseprite:dev"]="echo \"Error: no test specified\" && exit 1";
		["aseprite:build"]="echo \"Error: no test specified\" && exit 1";
		["aseprite:rmdir"]="echo \"Error: no test specified\" && exit 1";
	};
	dependencies={
		["internal.system"]="internal/system/init.lua";
		["internal.class"]="internal/class/init.lua";
		["internal.class.definitions"]="internal/class/class.lua";
		["internal.class.util"]="internal/class/util.lua";
		["internal.class.interface"]="internal/class/interface.lua";
		["init"]="lifecycle/init.lua";
		["logic"]="lifecycle/logic.lua";
		["main"]="lifecycle/main.lua";
		["interface"]="interfaces/index.lua";
		["interface.color"]="interfaces/color.lua";
		["interface.filter"]="interfaces/filter.lua";
		["color"]="color/index.lua";
		["color.harmonies"]="color/harmonies.lua";
		["color.filters"]="color/filters.lua";
		["color.transforms"]="color/transforms.lua";
		["image_processing"]="image_processing/index.lua";
		["image_processing.pixel"]="image_processing/pixel_handler.lua";
		["image_processing.transform"]="image_processing/transformations.lua";
		["languages"]="languages/index.lua";
		["languages.english"]="languages/english.lua";
		["languages.mandarin"]="languages/mandarin.lua";
		["languages.hindi"]="languages/hindi.lua";
		["languages.spanish"]="languages/spanish.lua";
		["languages.french"]="languages/french.lua";
		["languages.arab"]="languages/arab.lua";
		["languages.bengali"]="languages/bengali.lua";
		["languages.russian"]="languages/russian.lua";
		["languages.portuguese"]="languages/portuguese.lua";
		["languages.indonesian"]="languages/indonesian.lua";
		["languages.italiano"]="languages/italiano.lua";
		["languages.urdu"]="languages/urdu.lua";
		["languages.german"]="languages/german.lua";
		["languages.japanese"]="languages/japanese.lua";
		["languages.korean"]="languages/korean.lua";
		["languages.turkish"]="languages/turkish.lua";
		["languages.thai"]="languages/thai.lua";
	};
	devDependencies={
	};
};
