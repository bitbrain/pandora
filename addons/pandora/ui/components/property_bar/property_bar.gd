@tool
class_name PandoraPropertyBar extends HBoxContainer

signal property_added(scene: PackedScene)

var type_to_scene = {}
var _extensions_synced := false

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
	if not type_to_scene.has(type):
		return null
	return type_to_scene[type]

func add_extensions_button() -> void:
	# Build set of existing button types and remove any duplicates
	var existing_types := {}
	var removed_count := 0
	for child in get_children().duplicate():
		var ctrl = child.scene.instantiate()
		var type_name = ctrl.type
		ctrl.queue_free()
		if existing_types.has(type_name):
			remove_child(child)
			child.queue_free()
			removed_count += 1
		else:
			existing_types[type_name] = true
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
			if extension_property["enabled"] and not existing_types.has(ed_path):
				var extension_dir = DirAccess.open(extensions_dir + "/" + ed_path)
				assert(extension_dir.dir_exists("property_button"))
				var property_button_dir = DirAccess.open(extensions_dir + "/" + ed_path + "/property_button/")
				var scene_path : String = extensions_dir + "/" + ed_path + "/property_button/property_button.tscn"
				var scene = load(scene_path).instantiate()
				scene.visible = extension_property["show_on_top"]
				add_child(scene)

func ensure_extensions_loaded() -> void:
	if _extensions_synced:
		return
	# Rebuild type_to_scene from existing children to prevent duplicates
	# (handles state resets from @tool hot-reload or partial _ready() execution)
	for button in get_children():
		var ctrl = button.scene.instantiate()
		if not type_to_scene.has(ctrl.type):
			type_to_scene[ctrl.type] = button.scene
		ctrl.queue_free()
	# Add only truly missing extension buttons
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	var extensions_confs_map := PandoraSettings.get_extensions_confs_map()
	var extensions_dirs = PandoraSettings.get_extensions_dirs()
	for extensions_dir in extensions_dirs:
		if not extensions_confs_map.has(extensions_dir):
			continue
		var extensions_configuration_idx := extensions_confs_map[extensions_dir] as int
		var extensions_configuration := extensions_configurations[extensions_configuration_idx] as Dictionary
		var extension_properties := extensions_configuration["properties"] as Array
		for extension_property in extension_properties:
			var dir_name = extension_property["dir_name"]
			if type_to_scene.has(dir_name) or not extension_property["enabled"]:
				continue
			var scene_path: String = extensions_dir + "/" + dir_name + "/property_button/property_button.tscn"
			if not ResourceLoader.exists(scene_path):
				continue
			var button = load(scene_path).instantiate()
			button.visible = extension_property["show_on_top"]
			add_child(button)
			button.pressed.connect(_pressed.bind(button as PandoraPropertyButton))
			var scene_instance = button.scene.instantiate()
			type_to_scene[scene_instance.type] = button.scene
			scene_instance.queue_free()
	_extensions_synced = true

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
