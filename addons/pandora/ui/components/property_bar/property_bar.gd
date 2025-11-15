@tool
class_name PandoraPropertyBar extends HBoxContainer

signal property_added(scene: PackedScene)

var type_to_scene = {}

func _ready() -> void:
	add_extensions_button()
	for button in get_children():
		button.pressed.connect(_pressed.bind(button as PandoraPropertyButton))
		var scene_instance = button.scene.instantiate()
		type_to_scene[scene_instance.type] = button.scene
		scene_instance.queue_free()

func _pressed(button: PandoraPropertyButton) -> void:
	property_added.emit(button.scene)

func get_scene_by_type(type: String) -> PackedScene:
	return type_to_scene[type]

func add_extensions_button() -> void:
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	var extensions_confs_map := PandoraSettings.get_extensions_confs_map()
	var extensions_dirs = PandoraSettings.get_extensions_dirs()
	for extensions_dir in extensions_dirs:
		var extensions_configuration_idx := extensions_confs_map[extensions_dir] as int
		var extensions_configuration := extensions_configurations[extensions_configuration_idx] as Dictionary
		var extension_properties := extensions_configuration["properties"] as Array
		
		var main_dir = DirAccess.open(extensions_dir)
		for ed_path in main_dir.get_directories():
			var extension_property = extension_properties.filter(func(property: Dictionary): return property["dir_name"] == ed_path)[0] as Dictionary
			if extension_property["enabled"]:
				var extension_dir = DirAccess.open(extensions_dir + "/" + ed_path)
				assert(extension_dir.dir_exists("property_button"))
				var property_button_dir = DirAccess.open(extensions_dir + "/" + ed_path + "/property_button/")
				var scene_path : String = extensions_dir + "/" + ed_path + "/property_button/property_button.tscn"
				var scene = load(scene_path).instantiate()
				scene.visible = extension_property["show_on_top"]
				add_child(scene)

func updates_property_bar_buttons() -> void:
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	var extensions_confs_map := PandoraSettings.get_extensions_confs_map()
	var extensions_dirs = PandoraSettings.get_extensions_dirs()
	for extensions_dir in extensions_dirs:
		var extensions_configuration_idx := extensions_confs_map[extensions_dir] as int
		var extensions_configuration := extensions_configurations[extensions_configuration_idx] as Dictionary
		var extension_properties := extensions_configuration["properties"] as Array
		for extension_property in extension_properties:
			var btn = get_children().filter(func(node: Node): 
				var node_instance = node.scene.instantiate() 
				var check = node_instance.type == extension_property["dir_name"] 
				node_instance.queue_free() 
				return check)
			if btn:
				if extension_property["enabled"]:
					if extension_property["show_on_top"]:
						btn[0].show()
					else:
						btn[0].hide()
				else:
					btn[0].hide()
