-- language code --> https://gist.github.com/jrnk/8eb57b065ea0b098d571
-- language code native --> https://gist.github.com/joshuabaker/d2775b5ada7d1601bcd7b31cb4081981
local deep_copy, import_module, Fun = _ENV.deep_copy, _ENV.import_module, _ENV.Fun;

local english= import_module("languages.english");
local mandarin = nil; --import_module("languages.mandarin");
local hindi = nil; --import_module("languages.hindi");
local spanish= import_module("languages.spanish");
local french = nil; --import_module("languages.french");
local arab = nil; --import_module("languages.arab");
local bengali = nil; --import_module("languages.bengali");
local russian = nil; --import_module("languages.russian");
local portuguese = nil; --import_module("languages.portuguese");
local indonesian = nil; --import_module("languages.indonesian");
local italiano = nil; --import_module("languages.italiano");
local urdu = nil; --import_module("languages.urdu");
local german = nil; --import_module("languages.german");
local japanese = nil; --import_module("languages.japanese");
local korean = nil; --import_module("languages.korean");
local turkish = nil; --import_module("languages.turkish");
local thai = nil; --import_module("languages.thai");
local idioms_dirty={};


if (type(english) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=english;
end
if (type(mandarin) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=mandarin;
end
if (type(hindi) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=hindi;
end
if (type(spanish) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=spanish;
end
if (type(french) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=french;
end
if (type(arab) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=arab;
end
if (type(bengali) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=bengali;
end
if (type(russian) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=russian;
end
if (type(portuguese) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=portuguese;
end
if (type(indonesian) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=indonesian;
end
if (type(italiano) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=italiano;
end
if (type(urdu) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=urdu;
end
if (type(german) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=german;
end
if (type(japanese) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=japanese;
end
if (type(korean) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=korean;
end
if (type(turkish) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=turkish;
end
if (type(thai) ~="nil") then
	idioms_dirty[#idioms_dirty+1]=thai;
end

local texts={};
local constants={};
texts.languages={};
Fun.iter(idioms_dirty):each(function (value_lang)
		if (type(value_lang.lang)=="string") then
			texts.languages[#texts.languages+1]=value_lang.lang;
		end
		if (type(value_lang.constants)~="nil") then
			constants[value_lang.lang] = deep_copy(value_lang.constants);
		end
		if (type(value_lang.interfaces)=="table") then
			Fun.iter(value_lang.interfaces):each(function (key_ui, value_ui)
				if (type(texts[key_ui])=="nil") then
					texts[key_ui]={};
				end
				if (type(value_ui)=="table") then
					Fun.iter(value_ui):each(function (key_component, value_component)
						if (type(texts[key_ui][key_component])=="nil") then
							texts[key_ui][key_component]={};
						end
						if (type(value_component)=="string") then
							texts[key_ui][key_component][value_lang.lang]=value_component;
						elseif (type(value_component)=="table") then
							Fun.iter(value_component):each(function (key_property, value_property)
								if (type(texts[key_ui][key_component][key_property])=="nil") then
									texts[key_ui][key_component][key_property]={};
								end
								texts[key_ui][key_component][key_property][value_lang.lang]=value_property;
							end);
						end
					end);
				end
			end);
		end
	end
);

local print_table = nil;
print_table = function (table, key)
	local current_key, value = next(table, key)
	if type(value) == "nil" then
		return " }";
	elseif current_key == 1 then
		return "{ "..tostring(value)..print_table(table, current_key);
	else
		return ", "..tostring(value)..print_table(table, current_key);
	end
end;

_ENV.print_table = print_table;

local hash_on_table = function (table, search_value)
	for _, value in ipairs(table) do
		if value == search_value then return true end;
	end
	return false;
end

_ENV.TEXTS=texts;
_ENV.constants_dirty=constants;

if not hash_on_table(texts.languages, _ENV.languages_option) then
	_ENV.languages_option = "en";
end
-- _ENV.languages_option
if (type(_ENV.languages_option) ~= "nil") then
	_ENV.constants=deep_copy(_ENV.constants_dirty)[_ENV.languages_option];
end