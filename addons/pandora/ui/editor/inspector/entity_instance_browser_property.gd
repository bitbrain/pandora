extends EditorProperty


# The main control for editing the property.
var property_control := OptionButton.new()

var ids_to_entities = {}


func _init() -> void:
	# Add the control as a direct child of EditorProperty node.
	add_child.call_deferred(property_control)
	# Make sure the control is able to retain the focus.
	add_focusable(property_control)
	property_control.get_popup().id_pressed.connect(_on_id_selected)
	
	var all_entities = Pandora.get_all_entities()
	var id_counter = 0
	for entity in all_entities:
		property_control.get_popup().add_icon_item(load(entity.get_icon_path()), entity.get_entity_name(), id_counter)
		ids_to_entities[id_counter] = entity
		id_counter += 1


func _on_id_selected(id:int) -> void:
	var entity = ids_to_entities[id] as PandoraEntity
	emit_changed(get_edited_property(), entity)
	

func _update_property() -> void:
	var current_entity = get_edited_object()[get_edited_property()] as PandoraEntity
	for id in ids_to_entities.keys():
		if ids_to_entities[id] == current_entity:
			property_control.select(id)
			break
