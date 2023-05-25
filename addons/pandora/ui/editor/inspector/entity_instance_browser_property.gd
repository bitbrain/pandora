@tool
extends Control


@onready var entity_tree: Tree = $EntityTree


func _ready() -> void:
	var backend = Pandora.get_item_backend()
	entity_tree.set_data(backend.get_all())


func select(entity_instance:PandoraEntityInstance) -> void:
	print(str(entity_instance) + " selected.")
