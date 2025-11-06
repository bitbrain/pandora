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
	var extensions_dirs = PandoraSettings.get_extensions_dirs()
	for extensions_dir in extensions_dirs:
		var main_dir = DirAccess.open(extensions_dir)
		for ed_path in main_dir.get_directories():
			var extension_dir = DirAccess.open(extensions_dir + "/" + ed_path)
			assert(extension_dir.dir_exists("property_button"))
			var property_button_dir = DirAccess.open(extensions_dir + "/" + ed_path + "/property_button/")
			var scene_path : String = extensions_dir + "/" + ed_path + "/property_button/property_button.tscn"
			var scene = load(scene_path).instantiate()
			add_child(scene)
