local import_module, export = _ENV.import_module, _ENV.export;
export.module "object-oriented";
local classes = {};
local class_definitions = import_module("internal.class.definitions")(classes);
export.add "import" {class_definitions.import}
export.add "extends" {class_definitions.extends};
export.add "static" {class_definitions.static};
export.add "public" {class_definitions.public};
export.add "private" {class_definitions.private};
export.add "operators" {class_definitions.operators};
export.add "class" {class_definitions.class};
local interface_definitions = import_module("internal.class.interface")(classes);
export.add "interface" {interface_definitions.interface};
export.add "abstract_function" {interface_definitions.abstract_function};
export.add "implements" {interface_definitions.implements};
local util = import_module("internal.class.util")(classes);
export.add "is" {util.is};
export.add "show_warnings" {util.show_warnings};
export.add "allow_writing_to_objects" {util.allow_writing_to_objects};

return _ENV.export.modules();
