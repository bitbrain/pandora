@tool
class_name PandoraEditor extends Control


var selected_entity:PandoraEntity


@onready var create_category_button: Button = %CreateCategoryButton
@onready var create_entity_button: Button = %CreateEntityButton
@onready var delete_button: Button = %DeleteButton
@onready var save_button: Button = %SaveButton
@onready var reset_button: Button = %ResetButton
@onready var save_label: Label = %SaveLabel
@onready var version: Label = %Version
@onready var entity_search: LineEdit = %EntitySearch
@onready var entity_tree: Tree = %EntityTree
@onready var property_editor: HSplitContainer = %PropertyEditor


func _enter_tree() -> void:
	_populate_data.call_deferred()


func _ready() -> void:
	create_category_button.pressed.connect(_create_category)
	create_entity_button.pressed.connect(_create_entity)
	delete_button.pressed.connect(func(): entity_tree.queue_delete(selected_entity.get_entity_id()))
	reset_button.pressed.connect(_reset_to_saved_file)
	save_button.pressed.connect(_save)
	entity_tree.entity_selected.connect(_entity_selected)
	entity_tree.entity_selected.connect(property_editor.set_entity)
	entity_tree.selection_cleared.connect(_selection_cleared)
	entity_tree.selection_cleared.connect(func(): property_editor.set_entity(null))
	entity_tree.entity_deletion_issued.connect(_delete_entity)

	# set version
	var plugin_config:ConfigFile = ConfigFile.new()
	plugin_config.load("res://addons/pandora/plugin.cfg")
	version.text = "Pandora v" + plugin_config.get_value("plugin", "version")

	entity_search.text_changed.connect(entity_tree.search)
	property_editor.inherited_property_selected.connect(_on_inherited_property_selected)

	# Add any newly created entity directly to the tree
	Pandora.entity_added.connect(entity_tree.add_entity)


func apply_changes() -> void:
	_save()


func _create_category() -> void:
	if not selected_entity is PandoraCategory:
		Pandora.create_category("New Category")
	else:
		Pandora.create_category("New Category", selected_entity)


func _create_entity() -> void:
	if not selected_entity is PandoraCategory:
		return
	Pandora.create_entity("New Entity", selected_entity)


func _entity_selected(entity:PandoraEntity) -> void:
	create_category_button.disabled = not entity is PandoraCategory
	create_entity_button.disabled = not entity is PandoraCategory
	delete_button.disabled = entity == null
	selected_entity = entity


func _selection_cleared() -> void:
	selected_entity = null
	create_category_button.disabled = false
	create_entity_button.disabled = true
	delete_button.disabled = true


func _on_inherited_property_selected(category_id:String, property_name:String) -> void:
	entity_tree.select(category_id)
	property_editor.edit_key(property_name)


func _populate_data() -> void:
	if not Pandora.is_loaded():
		print("Unable to load data - Pandora not initialised!")
		return

	var data:Array[PandoraEntity] = []
	data.assign(Pandora.get_all_roots())
	entity_tree.set_data(data)

	if not Pandora.data_loaded.is_connected(_populate_data):
		Pandora.data_loaded.connect(_populate_data)

	create_category_button.disabled = false
	create_entity_button.disabled = true
	delete_button.disabled = true


func _delete_entity(entity:PandoraEntity) -> void:
	Pandora.delete_entity(entity)


func _save() -> void:
	Pandora.save_data()
	save_label.popup()


func _reset_to_saved_file() -> void:
	Pandora._clear()
	Pandora.load_data()
	var data:Array[PandoraEntity] = []
	data.assign(Pandora.get_all_roots())
	entity_tree.set_data(data)
	create_category_button.disabled = false
	create_entity_button.disabled = true
	delete_button.disabled = true
	property_editor.set_entity(null)
	_selection_cleared()
