extends CenterContainer

@export var entity:PandoraEntity


func _ready() -> void:
	print(entity.get_entity_name())
