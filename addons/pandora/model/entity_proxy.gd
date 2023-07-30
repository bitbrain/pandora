## Godot is capable of storing resources in .tscn files
## This is especially useful when assigning resources
## within the node property editor. However, data in Pandora
## is usually not stored as part of .tscn files but in a separate
## data.pandora file.
## This proxy ensures that we can store the entity id inside the
## .tscn file and then dynamically look up the actual entity
## at runtime by accessing Pandora's API.
@tool
class_name PandoraEntityProxy extends PandoraEntity


@export var proxied_entity_id:String


func _init() -> void:
	super._init("", "", "", "")
	
	
func instantiate() -> PandoraEntityInstance:
	return _get_entity().instantiate()


func get_entity_id() -> String:
	return proxied_entity_id
	
	
func get_entity_name() -> String:
	if _get_entity() == null:
		push_error("Pandora - entity not found!")
		return ""
	return _get_entity().get_entity_name()
	
	
func get_icon_path() -> String:
	if _get_entity() == null:
		push_error("Pandora - entity not found!")
		return ""
	return _get_entity().get_icon_path()
	
	
func get_category_id() -> String:
	if _get_entity() == null:
		push_error("Pandora - data not loaded yet.")
		return ""
	return _get_entity().get_category_id()
	
	
func get_entity_properties() -> Array[PandoraProperty]:
	if _get_entity() == null:
		push_error("Pandora - data not loaded yet.")
		return []
	return _get_entity().get_entity_properties()
	
	
func get_category() -> PandoraCategory:
	if _get_entity() == null:
		push_error("Pandora - data not loaded yet.")
		return null
	return _get_entity().get_category()


func load_data(data:Dictionary) -> void:
	# noOp
	pass
	
	
func save_data() -> Dictionary:
	return {}


func _get_entity() -> PandoraEntity:
	return Pandora.get_entity(proxied_entity_id)
