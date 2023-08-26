extends EditorProperty

# The main control for editing the property.
var property_control := OptionButton.new()
var ids_to_entities = {}


func _init(class_data:Dictionary) -> void:
	# Add the control as a direct child of EditorProperty node.
	add_child.call_deferred(property_control)
	# Make sure the control is able to retain the focus.
	add_focusable(property_control)
	property_control.get_popup().id_pressed.connect(_on_id_selected)
	
	var id_counter = 0
	var all_entities = _find_all_entities(class_data["path"])
	
	for entity in all_entities:
		property_control.get_popup().add_icon_item(load(entity.get_icon_path()), entity.get_entity_name(), id_counter)
		ids_to_entities[id_counter] = entity
		id_counter += 1


func _on_id_selected(id:int) -> void:
	var entity = ids_to_entities[id] as PandoraEntity
	var current_entity = get_edited_object()[get_edited_property()] as PandoraEntity

	if current_entity != null and entity.get_entity_id() == current_entity.get_entity_id():
		# skip current entities
		return
	
	emit_changed(get_edited_property(), entity)


func _update_property() -> void:
	_update_deferred.call_deferred()


func _update_deferred() -> void:
	var current_entity = get_edited_object()[get_edited_property()] as PandoraEntity
	if current_entity == null:
		return
	for id in ids_to_entities.keys():
		if ids_to_entities[id].get_entity_id() == current_entity.get_entity_id():
			property_control.select(id)
			break


## Looks up all entities who are eligible for the given script path
func _find_all_entities(script_path:String) -> Array[PandoraEntity]:
		# lookup entity data
	var categories = Pandora.get_all_categories()
	var all_entities:Array[PandoraEntity] = []
	for category in categories:
		if category._script_path == script_path:
			var entities = Pandora.get_all_entities(category)
			for entity in entities:
				all_entities.append(entity)
	if all_entities.is_empty():
		all_entities = Pandora.get_all_entities()
	return all_entities
