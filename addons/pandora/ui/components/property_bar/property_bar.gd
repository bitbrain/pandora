@tool
class_name PandoraPropertyBar extends HBoxContainer

signal property_added(scene: PackedScene)

@onready var _buttons = get_children()

var type_to_scene = {}


func _ready() -> void:
	for button in _buttons:
		button.pressed.connect(_pressed.bind(button as PandoraPropertyButton))
		var scene_instance = button.scene.instantiate()
		type_to_scene[scene_instance.type] = button.scene
		scene_instance.queue_free()


func _pressed(button: PandoraPropertyButton) -> void:
	property_added.emit(button.scene)


func get_scene_by_type(type: String) -> PackedScene:
	return type_to_scene[type]
