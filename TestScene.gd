extends CenterContainer

 
@export var entity:PandoraEntity
@export var texture:Texture2D


func _ready() -> void:
	var instance = Pandora.create_entity_instance(entity)
	print(PandoraEntityInstance.serialize(instance))
