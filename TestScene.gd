extends CenterContainer

 
@export var entity:PandoraEntity
@export var texture:Texture2D


func _ready() -> void:
	print(entity.get_entity_name())
