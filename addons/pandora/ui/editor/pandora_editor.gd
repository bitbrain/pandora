@tool
class_name PandoraEditor extends Control


@onready var tree:PandoraEntityTree = %EntityTree
@onready var save_button:Button = %SaveButton
@onready var reset_button = %ResetButton
@onready var create_entity_button:Button = %CreateEntityButton
@onready var create_category_button:Button = %CreateCategoryButton
@onready var import_button:Button = %ImportButton
@onready var delete_button = %DeleteButton
@onready var property_editor = %PropertyEditor
@onready var entity_search: LineEdit = %EntitySearch
@onready var version = %Version
@onready var save_label = %SaveLabel
@onready var file_dialog = %FileDialog
@onready var notification_dialog = %NotificationDialog

@onready var data_content = %DataContent
@onready var error_content = %ErrorContent



var selected_entity:PandoraEntity
var _load_error = false


func _ready() -> void:
	save_button.pressed.connect(_save)
	tree.entity_selected.connect(_entity_selected)
	tree.selection_cleared.connect(_selection_cleared)
	tree.entity_selected.connect(property_editor.set_entity)
	tree.selection_cleared.connect(func(): property_editor.set_entity(null))
	tree.entity_deletion_issued.connect(_delete_entity)
	create_entity_button.pressed.connect(_create_entity)
	create_category_button.pressed.connect(_create_category)
	reset_button.pressed.connect(_reset_to_saved_file)
	delete_button.pressed.connect(func(): tree.queue_delete(selected_entity.get_entity_id()))
	import_button.pressed.connect(func(): file_dialog.popup_centered())
	file_dialog.file_selected.connect(_import_file)
	
	# set version
	var plugin_config:ConfigFile = ConfigFile.new()
	plugin_config.load("res://addons/pandora/plugin.cfg")
	version.text = "Pandora v" + plugin_config.get_value("plugin", "version")
	
	entity_search.text_changed.connect(tree.search)
	property_editor.inherited_property_selected.connect(_on_inherited_property_selected)
	
	# Add any newly created entity directly to the tree
	Pandora.entity_added.connect(tree.add_entity)
	Pandora.data_loaded.connect(self._data_load_success)
	Pandora.data_loaded_failure.connect(self._data_load_failure)
	Pandora.import_ended.connect(self._on_import_ended)


func reattempt_load_on_error() -> void:
	if _load_error:
		_reset_to_saved_file()
	
	
func apply_changes() -> void:
	_save()


func _enter_tree() -> void:
	_populate_data.call_deferred()
	
	
func _entity_selected(entity:PandoraEntity) -> void:
	create_entity_button.disabled = not entity is PandoraCategory
	create_category_button.disabled = not entity is PandoraCategory
	delete_button.disabled = entity == null
	selected_entity = entity
	
	
func _selection_cleared() -> void:
	selected_entity = null
	create_entity_button.disabled = true
	create_category_button.disabled = false
	delete_button.disabled = true
	
	
func _on_inherited_property_selected(category_id:String, property_name:String) -> void:
	tree.select(category_id)
	property_editor.edit_key(property_name)
	
	
func _create_entity() -> void:
	if not selected_entity is PandoraCategory:
		return
	Pandora.create_entity("New Entity", selected_entity)
	
	
func _create_category() -> void:
	if not selected_entity is PandoraCategory:
		Pandora.create_category("New Category")
	else:
		Pandora.create_category("New Category", selected_entity)
	

func _populate_data() -> void:
	if not Pandora.is_loaded():
		print("Unable to load data - Pandora not initialised!")
		return
	
	var data:Array[PandoraEntity] = []
	data.assign(Pandora.get_all_roots())
	tree.set_data(data)
	
	if not Pandora.data_loaded.is_connected(_populate_data):
		Pandora.data_loaded.connect(_populate_data)
		
	create_entity_button.disabled = true
	create_category_button.disabled = false
	delete_button.disabled = true
	
	
func _save() -> void:
	Pandora.save_data()
	save_label.popup()


func _delete_entity(entity:PandoraEntity) -> void:
	Pandora.delete_entity(entity)


func _reset_to_saved_file() -> void:
	Pandora._clear()
	Pandora.load_data()
	var data:Array[PandoraEntity] = []
	data.assign(Pandora.get_all_roots())
	tree.set_data(data)
	create_entity_button.disabled = true
	create_category_button.disabled = false
	delete_button.disabled = true
	property_editor.set_entity(null)
	_selection_cleared()
	
	
func _data_load_success() -> void:
	data_content.visible = true
	error_content.visible = false
	_load_error = false
	
	
func _data_load_failure() -> void:
	data_content.visible = false
	error_content.visible = true
	_load_error = true

func _import_file(path: String) -> void:
	tree.loading_spinner.visible = true
	data_content.visible = false
	Pandora.import_data(path)
	
func _on_import_ended(response: String, imported_count: int = 0) -> void:
	tree.loading_spinner.visible = false
	data_content.visible = true
	if response != "OK":
		notification_dialog.title = "Import Failed!"
		notification_dialog.dialog_text = response
		notification_dialog.popup_centered()
		return
	
	var data:Array[PandoraEntity] = []
	data.assign(Pandora.get_all_roots())
	tree.set_data(data)
	create_entity_button.disabled = true
	create_category_button.disabled = false
	delete_button.disabled = true
	property_editor.set_entity(null)
	
	notification_dialog.title = "Import Finished!"
	notification_dialog.dialog_text = str(imported_count) + " records imported successfully!"
	notification_dialog.popup_centered()
