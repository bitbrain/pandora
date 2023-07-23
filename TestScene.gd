extends CenterContainer

 
@export var entity:PandoraEntity
@export var texture:Texture2D


func _ready() -> void:
	var instance = Pandora.create_entity_instance(entity)
	print(Pandora.serialize_entity_instance(instance))
	
	var entity = Pandora.get_entity(EntityIds.NEW_ENTITY)
