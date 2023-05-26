@tool
extends CenterContainer

@export var entity:PandoraEntity


func _process(delta: float) -> void:
	if entity != null:
		print(entity.get_entity_id())
