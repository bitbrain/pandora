@tool
class_name PandoraEditor extends Control

@onready var tree: PandoraEntityTree = %EntityTree
@onready var save_button: Button = %SaveButton
@onready var reset_button = %ResetButton
@onready var create_entity_button: Button = %CreateEntityButton
@onready var create_category_button: Button = %CreateCategoryButton
@onready var import_button: Button = %ImportButton
@onready var delete_button = %DeleteButton
@onready var property_editor = %PropertyEditor
@onready var regenerate_id_button: Button = %RegenerateIDButton
@onready var entity_search: LineEdit = %EntitySearch
@onready var version = %Version
@onready var save_label = %SaveLabel
@onready var import_dialog = %ImportDialog
@onready var progress_bar = %ProgressBar
@onready var category_tab_container: TabContainer = %CategoryTabContainer
@onready var tree_scroll_container: ScrollContainer = %TreeScrollContainer

@onready var data_content = %DataContent
@onready var error_content = %ErrorContent

var selected_entity: PandoraEntity
var _load_error = false
var _current_tab_category: PandoraCategory = null
var tab_context_menu: PopupMenu


func _ready() -> void:
	save_button.pressed.connect(_save)
	tree.entity_selected.connect(_entity_selected)
	tree.selection_cleared.connect(_selection_cleared)
	tree.entity_selected.connect(property_editor.set_entity)
	tree.selection_cleared.connect(func(): property_editor.set_entity(null))
	tree.entity_deletion_issued.connect(_delete_entity)
	tree.entity_moved.connect(_move_entity)
	create_entity_button.pressed.connect(_create_entity)
	create_category_button.pressed.connect(_create_category)
	regenerate_id_button.pressed.connect(_on_regenerate_id_button_pressed)
	reset_button.pressed.connect(_reset_to_saved_file)
	delete_button.pressed.connect(func(): tree.queue_delete(selected_entity.get_entity_id()))
	import_button.pressed.connect(func(): import_dialog.open())
	import_dialog.import_started.connect(func(import_count: int): progress_bar.init(import_count))
	import_dialog.import_ended.connect(_on_import_ended)

	# set version
	var plugin_config: ConfigFile = ConfigFile.new()
	plugin_config.load("res://addons/pandora/plugin.cfg")
	version.text = "Pandora v" + plugin_config.get_value("plugin", "version")

	entity_search.text_changed.connect(tree.search)
	property_editor.inherited_property_selected.connect(_on_inherited_property_selected)

	# Add any newly created entity directly to the tree
	Pandora.entity_added.connect(tree.add_entity)
	Pandora.data_loaded.connect(self._data_load_success)
	Pandora.data_loaded_failure.connect(self._data_load_failure)
	Pandora.import_progress.connect(self._on_progress)

	# Handle file system changes
	if Engine.is_editor_hint():
		EditorInterface.get_file_system_dock().file_removed.connect(_handle_file_deleted)
		EditorInterface.get_file_system_dock().files_moved.connect(_handle_file_moved)

	# Listen for settings changes
	ProjectSettings.settings_changed.connect(_on_settings_changed)

	# Tab context menu
	tab_context_menu = PopupMenu.new()
	tab_context_menu.add_item("Rename", 0)
	tab_context_menu.add_separator()
	tab_context_menu.add_item("Delete", 1)
	tab_context_menu.id_pressed.connect(_on_tab_context_menu_pressed)
	add_child(tab_context_menu)


func reattempt_load_on_error() -> void:
	if _load_error:
		_reset_to_saved_file()


func apply_changes() -> void:
	_save()


func _enter_tree() -> void:
	_populate_data.call_deferred()


func _entity_selected(entity: PandoraEntity) -> void:
	create_entity_button.disabled = not entity is PandoraCategory
	create_category_button.disabled = not entity is PandoraCategory
	regenerate_id_button.disabled = not entity is PandoraEntity
	delete_button.disabled = entity == null
	selected_entity = entity


func _selection_cleared() -> void:
	selected_entity = null
	create_entity_button.disabled = true
	create_category_button.disabled = false
	regenerate_id_button.disabled = true
	delete_button.disabled = true


func _on_inherited_property_selected(category_id: String, property_name: String) -> void:
	tree.select(category_id)
	property_editor.edit_key(property_name)


func _create_entity() -> void:
	var use_tabs = PandoraSettings.get_use_category_tabs()

	if use_tabs and _current_tab_category != null:
		# In tab mode: create entity in the current tab's category
		Pandora.create_entity("New Entity", _current_tab_category)
	elif not selected_entity is PandoraCategory:
		return
	else:
		# Default: create in selected category
		Pandora.create_entity("New Entity", selected_entity)


func _create_category() -> void:
	var use_tabs = PandoraSettings.get_use_category_tabs()

	if use_tabs and _current_tab_category != null:
		# In tab mode: create subcategory under current tab
		Pandora.create_category("New Category", _current_tab_category)
	elif not selected_entity is PandoraCategory:
		# No selection: create root category
		Pandora.create_category("New Category")
	else:
		# Default: create subcategory under selected
		Pandora.create_category("New Category", selected_entity)


func _regenerate_all_ids() -> void:
	Pandora.regenerate_all_ids()


func _regenerate_id(entity: PandoraEntity) -> void:
	if selected_entity is PandoraCategory:
		Pandora.regenerate_category_id(entity)
	else:
		Pandora.regenerate_entity_id(entity)


func _populate_data() -> void:
	if not Pandora.is_loaded():
		print("Unable to load data - Pandora not initialised!")
		return

	var data: Array[PandoraEntity] = []
	data.assign(Pandora.get_all_roots())

	var use_tabs = PandoraSettings.get_use_category_tabs()

	if use_tabs:
		await _populate_tabs(data)
	else:
		tree.set_data(data)

	if not Pandora.data_loaded.is_connected(_populate_data):
		Pandora.data_loaded.connect(_populate_data)

	create_category_button.disabled = false
	regenerate_id_button.disabled = true
	delete_button.disabled = true
	create_entity_button.disabled = not use_tabs

	category_tab_container.visible = use_tabs
	create_category_button.visible = not use_tabs


func _populate_tabs(root_categories: Array[PandoraEntity], select_tab_index: int = 0) -> void:
	if category_tab_container.tab_changed.is_connected(_on_tab_changed):
		category_tab_container.tab_changed.disconnect(_on_tab_changed)
	# Clear existing tabs
	for child in category_tab_container.get_children():
		child.queue_free()

	await get_tree().process_frame

	# Create tabs for root categories
	for i in range(root_categories.size()):
		var tab_content = Control.new()
		category_tab_container.add_child(tab_content)
		category_tab_container.set_tab_title(i, root_categories[i].get_entity_name())

	# Add '+' tab for creating new root categories
	var add_tab_content = Control.new()
	add_tab_content.name = "+"
	category_tab_container.add_child(add_tab_content)

	# Connect tab change signal to filter the tree
	if not category_tab_container.tab_changed.is_connected(_on_tab_changed):
		category_tab_container.tab_changed.connect(_on_tab_changed)

	# Connect right-click on tab bar to show context menu
	var tab_bar = category_tab_container.get_tab_bar()
	if not tab_bar.gui_input.is_connected(_on_tab_bar_input):
		tab_bar.gui_input.connect(_on_tab_bar_input)

	# Store root categories
	category_tab_container.set_meta("root_categories", root_categories)

	# Select tab
	if root_categories.size() > 0:
		category_tab_container.current_tab = select_tab_index
		_on_tab_changed(select_tab_index)


func _on_tab_changed(tab_index: int) -> void:
	var root_categories = category_tab_container.get_meta("root_categories", []) as Array

	# Create new root category if '+' tab is selected
	if tab_index >= root_categories.size():
		_create_root_category()
		return

	if tab_index < 0:
		return

	# Show selected category
	var selected_category = root_categories[tab_index]
	_current_tab_category = selected_category

	# Filter tree to show only entities in the selected category
	var filtered_data: Array[PandoraEntity] = []
	if selected_category is PandoraCategory:
		filtered_data.assign(selected_category._children)

	tree.set_data(filtered_data)

	# Show the parent category's properties in the property editor
	property_editor.set_entity(selected_category)
	selected_entity = selected_category


func _create_root_category() -> void:
	Pandora.create_category("New Category")

	var data: Array[PandoraEntity] = []
	data.assign(Pandora.get_all_roots())

	# Select the newly created tab
	_populate_tabs(data, data.size() - 1)


func _save() -> void:
	Pandora.save_data()
	save_label.popup()


func _delete_entity(entity: PandoraEntity) -> void:
	Pandora.delete_entity(entity)


func _move_entity(
	source: PandoraEntity, target: PandoraEntity, drop_section: PandoraEntityBackend.DropSection
) -> void:
	Pandora.move_entity(source, target, drop_section)


func _reset_to_saved_file() -> void:
	Pandora._clear()
	Pandora.load_data()
	var data: Array[PandoraEntity] = []
	data.assign(Pandora.get_all_roots())

	var use_tabs = PandoraSettings.get_use_category_tabs()
	if use_tabs:
		category_tab_container.visible = true
		create_category_button.visible = false
		await _populate_tabs(data)
	else:
		category_tab_container.visible = false
		create_category_button.visible = true
		tree.set_data(data)

	create_entity_button.disabled = true
	create_category_button.disabled = false
	regenerate_id_button.disabled = true
	delete_button.disabled = true
	property_editor.set_entity(null)
	_selection_cleared()


func _on_regenerate_id_button_pressed() -> void:
	if Input.is_physical_key_pressed(KEY_SHIFT):
		_regenerate_all_ids()
	else:
		_regenerate_id(selected_entity)
	_populate_data()


func _data_load_success() -> void:
	data_content.visible = true
	error_content.visible = false
	_load_error = false


func _data_load_failure() -> void:
	data_content.visible = false
	error_content.visible = true
	_load_error = true


func _on_progress() -> void:
	progress_bar.advance()


func _on_import_ended(data: Array[PandoraEntity]) -> void:
	tree.set_data(data)
	create_entity_button.disabled = true
	create_category_button.disabled = false
	delete_button.disabled = true
	property_editor.set_entity(null)
	progress_bar.finish()
	save_button.disabled = false
	reset_button.disabled = false
	import_button.disabled = false


func _handle_file_moved(old_path: String, new_path: String) -> void:
	var entities: Array[PandoraEntity] = []
	entities.append_array(Pandora.get_all_entities())
	entities.append_array(Pandora.get_all_categories())
	for entity in entities:
		if entity.get_icon_path() == old_path:
			entity._icon_path = new_path

		# Handle properties which we can't automatically update,
		# like strings. We don't need to update resources as they
		# are automatically updated by the engine.
		for property in entity._properties:
			if property.get_property_type() == null:
				continue
			if property.get_default_value() == null:
				continue
			if property.get_property_type()._type_name == "string" && property._default_value == old_path:
					property._default_value = new_path
	await Engine.get_main_loop().process_frame

	Pandora.save_data()
	_populate_data.call_deferred()
	for property in property_editor.property_list.get_children():
		property._refresh()

func _handle_file_deleted(file: String) -> void:
	await _handle_file_moved(file, "")


func _on_tab_bar_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var tab_bar = category_tab_container.get_tab_bar()
		var clicked_tab = tab_bar.get_tab_idx_at_point(event.position)

		if clicked_tab >= 0:
			var root_categories = category_tab_container.get_meta("root_categories", []) as Array

			# Don't show menu for '+' tab
			if clicked_tab >= root_categories.size():
				return

			# Store which tab was clicked
			category_tab_container.set_meta("context_menu_tab", clicked_tab)

			# Show context menu
			tab_context_menu.position = tab_bar.get_screen_position() + event.position
			tab_context_menu.popup()


func _on_tab_context_menu_pressed(id: int) -> void:
	var clicked_tab = category_tab_container.get_meta("context_menu_tab", -1)
	if clicked_tab < 0:
		return

	var root_categories = category_tab_container.get_meta("root_categories", []) as Array
	if clicked_tab >= root_categories.size():
		return

	var category = root_categories[clicked_tab]

	match id:
		0:  # Rename
			_show_rename_dialog(category, clicked_tab)
		1:  # Delete
			_show_delete_confirmation(category, clicked_tab)


func _show_rename_dialog(category: PandoraCategory, tab_index: int) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "Rename Category"
	dialog.dialog_text = "Enter new name:"

	var line_edit = LineEdit.new()
	line_edit.text = category.get_entity_name()
	line_edit.select_all()
	line_edit.custom_minimum_size = Vector2i(300, 0)
	dialog.add_child(line_edit)

	add_child(dialog)

	dialog.confirmed.connect(func():
		var new_name = line_edit.text.strip_edges()
		if new_name != "":
			category.set_entity_name(new_name)
			category_tab_container.set_tab_title(tab_index, new_name)

			if selected_entity == category:
				property_editor.set_entity(category)

		dialog.queue_free()
	)

	dialog.canceled.connect(func():
		dialog.queue_free()
	)

	dialog.popup_centered()
	line_edit.grab_focus()

	# Submit on Enter - just press the OK button
	line_edit. text_submitted.connect(func(_text):
		dialog.get_ok_button().pressed.emit()
	)


func _show_delete_confirmation(category: PandoraCategory, tab_index: int) -> void:
	var dialog = ConfirmationDialog.new()
	dialog.dialog_text = "Delete category '%s' and all its contents?" % category.get_entity_name()
	dialog.title = "Confirm Deletion"

	add_child(dialog)

	dialog.confirmed.connect(func():
		# Delete the category
		Pandora.delete_entity(category)

		# Refresh tabs
		var data:  Array[PandoraEntity] = []
		data.assign(Pandora.get_all_roots())

		if data.size() > 0:
			# Select first tab or the one before deleted
			var new_tab = min(tab_index, data.size() - 1)
			_populate_tabs(data, new_tab)
		else:
			# No categories left
			_populate_tabs(data, 0)

		dialog.queue_free()
	)

	dialog.canceled.connect(func():
		dialog.queue_free()
	)

	dialog.popup_centered()


func _on_settings_changed() -> void:
	_populate_data()
