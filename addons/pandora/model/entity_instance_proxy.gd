class_name PandoraEntityInstanceProxy extends PandoraEntityInstance


@export var proxied_entity_instance_id:String


func _init() -> void:
	super._init("", "", [])


func get_entity() -> PandoraEntity:
	if _get_entity_instance() == null:
		push_error("Pandora - data not loaded yet.")
		return null
	return _get_entity_instance().get_entity()
	
	
func get_category() -> PandoraCategory:
	if _get_entity_instance() == null:
		push_error("Pandora - data not loaded yet.")
		return null
	return _get_entity_instance().get_category()

		
func get_string(property_name:String) -> String:
	if _get_entity_instance() == null:
		push_error("Pandora - data not loaded yet.")
		return ""
	return _get_entity_instance().get_string(property_name)
	
	
func get_integer(property_name:String) -> int:
	if _get_entity_instance() == null:
		push_error("Pandora - data not loaded yet.")
		return 0
	return _get_entity_instance().get_integer(property_name)
	
	
func get_float(property_name:String) -> float:
	if _get_entity_instance() == null:
		push_error("Pandora - data not loaded yet.")
		return 0.0
	return _get_entity_instance().get_float(property_name)
	
	
func get_bool(property_name:String) -> bool:
	if _get_entity_instance() == null:
		push_error("Pandora - data not loaded yet.")
		return false
	return _get_entity_instance().get_bool(property_name)
	
	
func get_color(property_name:String) -> Color:
	if _get_entity_instance() == null:
		push_error("Pandora - data not loaded yet.")
		return Color.WHITE
	return _get_entity_instance().get_color(property_name)


func load_data(data:Dictionary) -> void:
	# NoOp
	pass
	
	
func save_data() -> Dictionary:
	return {}


func _get_entity_instance() -> PandoraEntityInstance:
	return Pandora.get_entity_instance(proxied_entity_instance_id)
