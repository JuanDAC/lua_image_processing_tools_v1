-- local system_lang_list = io.popen('systeminfo | findstr /R /C:"[a-z]*;[a-zA-Z]* *("');
-- local langs = {};
-- for system_lang_item in system_lang_list:lines() do
-- 	langs[#langs + 1] = system_lang_item:match("%s[a-z]+"):match("[a-z]+");
-- end
-- print(langs[#langs]);



local system_resolution = io.popen('wmic path Win32_VideoController  get CurrentHorizontalResolution,CurrentVerticalResolution /format:value');
local resolution = load("return {"..( system_resolution:read("*a"):gsub("%s", ""):gsub("%d+", "%0;") ).."};")();

print(resolution.CurrentHorizontalResolution);
print(resolution.CurrentVerticalResolution);
