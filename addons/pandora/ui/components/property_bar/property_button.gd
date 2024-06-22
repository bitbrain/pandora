class_name PandoraPropertyButton extends Button

@export var scene: PackedScene


func _ready():
	if scene:
		var scene_instance = scene.instantiate()
		var property_type = PandoraPropertyType.lookup(scene_instance.type)
		icon = load(property_type.get_type_icon_path())
		scene_instance.queue_free()
