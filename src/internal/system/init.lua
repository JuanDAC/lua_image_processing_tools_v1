local system_lang_list=io.popen('systeminfo | findstr /R /C:"[a-z]*;[a-zA-Z]* *("');
local langs={};
for system_lang_item in system_lang_list:lines() do
	langs[#langs + 1]=system_lang_item:match("%s[a-z]+"):match("[a-z]+");
end
_ENV.languages_option=langs[#langs];

-- local this_path = io.popen("powershell Split-Path -leaf -path (Get-Location)"):read("*all");
-- app.alert(tostring(this_path));

local system_resolution=io.popen('wmic path Win32_VideoController  get CurrentHorizontalResolution,CurrentVerticalResolution /format:value');
_ENV.resolution=load("return {"..( system_resolution:read("*a"):gsub("%s", ""):gsub("%d+", "%0;") ).."};")();
local inverse_pixel_percentage=0.5;
_ENV.resolution.CurrentHorizontalResolution=math.floor(_ENV.resolution.CurrentHorizontalResolution * inverse_pixel_percentage);
_ENV.resolution.CurrentVerticalResolution=math.floor(_ENV.resolution.CurrentVerticalResolution * inverse_pixel_percentage);

return {
	languages_option=_ENV.languages_option;
}