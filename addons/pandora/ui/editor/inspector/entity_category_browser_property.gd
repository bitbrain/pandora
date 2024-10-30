extends EditorProperty

# The main control for editing the property.
var property_control := OptionButton.new()
var ids_to_categories = {}


func _init(class_data: Dictionary) -> void:
	# Add the control as a direct child of EditorProperty node.
	add_child.call_deferred(property_control)
	# Make sure the control is able to retain the focus.
	add_focusable(property_control)
	property_control.get_popup().id_pressed.connect(_on_id_selected)

	var id_counter = 0
	var all_categories = _find_all_categories(class_data["path"])
	var editor_plugin: EditorPlugin = Engine.get_meta("PandoraEditorPlugin", null)
	# Prevent button from expanding to selected icon size.
	property_control.set_expand_icon(true)

	for category in all_categories:
		property_control.get_popup().add_icon_item(
			load(category.get_icon_path()), category.get_entity_name(), id_counter
		)
		if editor_plugin:
			property_control.get_popup().set_item_icon_max_width(id_counter, editor_plugin.get_editor_interface().get_editor_scale() * 16)
		# Godot 4.1+
		if property_control.get_popup().has_method("set_item_icon_modulate"):
			property_control.get_popup().set_item_icon_modulate(id_counter, category.get_icon_color())
		ids_to_categories[id_counter] = category
		id_counter += 1


func _on_id_selected(id: int) -> void:
	var category = ids_to_categories[id] as PandoraEntity
	var current_category = get_edited_object()[get_edited_property()] as PandoraEntity
	
	property_control.modulate = (
		current_category.get_icon_color() if current_category != null else Color.WHITE
	)
	if current_category != null and category.get_entity_id() == current_category.get_entity_id():
		# skip current entities
		return

	emit_changed(get_edited_property(), category)


func _update_property() -> void:
	_update_deferred()


func _update_deferred() -> void:
	var current_category = get_edited_object()[get_edited_property()] as PandoraEntity
	if current_category == null:
		property_control.select(-1)
		return
	for id in ids_to_categories.keys():
		if ids_to_categories[id].get_entity_id() == current_category.get_entity_id():
			property_control.select(id)
			property_control.modulate = current_category.get_icon_color()
			break


## Looks up all categories who are eligible for the given script path
func _find_all_categories(script_path: String) -> Array[PandoraEntity]:
	# lookup entity data
	var categories = Pandora.get_all_categories()
	var all_categories: Array[PandoraEntity] = []
	for category in categories:
		if category._script_path == script_path:
			all_categories.append(category)
	if all_categories.is_empty():
		all_categories = Pandora.get_all_categories()
	return all_categories
