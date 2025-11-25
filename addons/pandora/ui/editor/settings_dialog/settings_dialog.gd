@tool
extends Control

signal update_extensions_configurations

const DependencyScene = preload("uid://dn5yxfosec2ta")
const STRING_FIELD_SETTINGS = preload("uid://bn7da5ljy5mqh")
const RANGE_FIELD_SETTINGS = preload("uid://cyd24jwivayf5")
const ARRAY_FIELD_SETTINGS = preload("uid://cgwd2gdv7xeia")
const REFERENCE_FIELD_SETTINGS = preload("uid://d3a0188wd61px")
const OPTIONS_FIELD_SETTINGS = preload("uid://7c8j3yx3hnr4")

@onready var window: Window = $Window
@onready var extensions_list: ItemList = $Window/PanelContainer/HBoxContainer/ExtensionsContainer/ItemList
@onready var extension_label: Label = $Window/PanelContainer/HBoxContainer/VBoxContainer/Label
@onready var select_extension_label: Label = %SelectExtension
@onready var no_properties_label: Label = %NoProperties
@onready var ext_configuration_container: VBoxContainer = %ExtConfigurationContainer

@onready var ext_properties_list: ItemList = %PropertyItemList
@onready var ext_property_desc: Label = %PropertyDescription
@onready var ext_property_enable_btn: CheckButton = %EnableButton
@onready var ext_property_show_on_top_btn: CheckButton = %ShowPropertyOnTop
@onready var customization_container: FoldableContainer = %CustomizationContainer
@onready var dependencies_container: FoldableContainer = %DependenciesContainer
@onready var properties_dependencies: VBoxContainer = %PropertiesDependencies
@onready var entities_dependencies: VBoxContainer = %EntitiesDependencies
@onready var properties_dependencies_container: GridContainer = %PropertiesDependencies/GridContainer
@onready var entities_dependencies_container: GridContainer = %EntitiesDependencies/GridContainer
@onready var ext_property_details: VBoxContainer = %PropertyContainer

@onready var creation_dialog: ConfirmationDialog = $Window/CreationDialog
@onready var creation_name_edit: LineEdit = $Window/CreationDialog/VBoxContainer/HBoxContainer/VBoxContainer/LineEdit
@onready var creation_type_edit: LineEdit = $Window/CreationDialog/VBoxContainer/HBoxContainer/VBoxContainer2/LineEdit2
@onready var creation_description_edit: TextEdit = $Window/CreationDialog/VBoxContainer/VBoxContainer/TextEdit

@onready var dependency_dialog: ConfirmationDialog = $Window/DependencyDialog
@onready var extensions_properties_selector: OptionButton = $Window/DependencyDialog/VBoxContainer/OptionButton
@onready var dependency_type_edit: LineEdit = $Window/DependencyDialog/VBoxContainer/LineEdit
@onready var enable_dialog: ConfirmationDialog = $Window/EnableDialog
@onready var dependency_check_alert: AcceptDialog = $Window/DependencyCheckAlert

@onready var property_scene_container: MarginContainer = %PropertySceneContainer
@onready var fields_settings: VBoxContainer = %FieldsSettings

var _selected_extension_conf_index : int
var _selected_extension_property_index : int
var _selected_dependency : Dictionary

func _ready() -> void:
	window.hide()
	hide()

func _load_configurations() -> void:
	extensions_list.clear()
	
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	for extensions_configuration in extensions_configurations:
		var item_name = extensions_configuration["configuration"]["name"] as String
		var item_icon = load(extensions_configuration["configuration"]["icon"] as String)
		
		if item_name == "Pandora":
			item_name = "Default"
		extensions_list.add_item(item_name, item_icon)
	no_properties_label.hide()
	ext_configuration_container.hide()
	ext_property_details.hide()
	select_extension_label.show()

func open():
	_load_configurations()
	
	show()
	window.show()

func _on_close_requested() -> void:
	_selected_extension_conf_index = -1
	_selected_extension_property_index = -1
	
	window.hide()
	hide()

func _on_item_selected(index: int) -> void:
	_selected_extension_conf_index = index
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	var extensions_configuration := extensions_configurations[index]
	extension_label.text = "%s - Extensions Settings" % extensions_configuration["configuration"]["name"]
	
	no_properties_label.hide()
	select_extension_label.hide()
	ext_configuration_container.hide()
	if not extensions_configuration["properties"]:
		no_properties_label.show()
	else:
		ext_properties_list.clear()
		
		for extension_property in extensions_configuration["properties"]:
			ext_properties_list.add_item(extension_property["name"])
		
		ext_configuration_container.show()

func _on_property_selected(index: int) -> void:
	_selected_extension_property_index = index
	for child in properties_dependencies_container.get_children():
		child.queue_free()
	for child in entities_dependencies_container.get_children():
		child.queue_free()
	for child in fields_settings.get_children():
		child.queue_free()
	if property_scene_container.get_child_count() > 0:
		property_scene_container.get_child(0).queue_free()
	
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	var extensions_configuration := extensions_configurations[_selected_extension_conf_index]
	var extension_property = extensions_configurations[_selected_extension_conf_index]["properties"][index] as Dictionary
	
	ext_property_desc.text = extension_property["description"]
	ext_property_enable_btn.button_pressed = extension_property["enabled"]
	ext_property_show_on_top_btn.button_pressed = extension_property["show_on_top"]
	var dependencies : Array = extension_property["dependencies"]
	var property_dependencies := dependencies.filter(func(dep: Dictionary): return dep["type"] == "PROPERTY")
	var model_dependencies := dependencies.filter(func(dep: Dictionary): return dep["type"] == "MODEL")
	if property_dependencies:
		for dep in property_dependencies:
			var dependency_scene : Dependency = DependencyScene.instantiate()
			dependency_scene.dependency = dep
			properties_dependencies_container.add_child(dependency_scene)
			dependency_scene.removed.connect(_on_dependency_removed)
	if model_dependencies:
		for dep in model_dependencies:
			var dependency_scene : Dependency = DependencyScene.instantiate()
			dependency_scene.dependency = dep
			entities_dependencies_container.add_child(dependency_scene)
			dependency_scene.removed.connect(_on_dependency_removed)
	var extension_dir = PandoraSettings.get_extensions_confs_map().find_key(_selected_extension_conf_index)
	var property_scene := (load(extension_dir + "/" + extension_property["dir_name"] + "/ui_component/" + extension_property["dir_name"] + ".tscn") as PackedScene).instantiate()
	property_scene_container.add_child(property_scene)
	
	if extension_property["fields"]:
		for property_field in extension_property["fields"]:
			if property_field["type"] == "STRING":
				var field_instance := STRING_FIELD_SETTINGS.instantiate() as StringFieldSettings
				fields_settings.add_child(field_instance)
				field_instance.set_property_field(property_field)
				field_instance.updated.connect(_on_field_settings_update)
			elif property_field["type"] == "RANGE":
				var field_instance := RANGE_FIELD_SETTINGS.instantiate() as RangeFieldSettings
				fields_settings.add_child(field_instance)
				field_instance.set_property_field(property_field)
				field_instance.updated.connect(_on_field_settings_update)
			elif property_field["type"] == "ARRAY":
				var field_instance := ARRAY_FIELD_SETTINGS.instantiate() as ArrayFieldSettings
				fields_settings.add_child(field_instance)
				field_instance.set_property_field(property_field)
				field_instance.updated.connect(_on_field_settings_update)
			elif property_field["type"] == "REFERENCE":
				var field_instance := REFERENCE_FIELD_SETTINGS.instantiate() as ReferenceFieldSettings
				fields_settings.add_child(field_instance)
				field_instance.set_property_field(property_field)
				field_instance.updated.connect(_on_field_settings_update)
			elif property_field["type"] == "OPTIONS":
				var field_instance := OPTIONS_FIELD_SETTINGS.instantiate() as OptionsFieldSettings
				fields_settings.add_child(field_instance)
				field_instance.set_property_field(property_field)
				field_instance.updated.connect(_on_field_settings_update)
	
	if not extension_property["enabled"]:
		ext_property_show_on_top_btn.disabled = true
		dependencies_container.modulate.a = 0.45
		customization_container.modulate.a = 0.45
	else:
		ext_property_show_on_top_btn.disabled = false
		dependencies_container.modulate.a = 1
		customization_container.modulate.a = 1
	ext_property_details.show()

func _on_field_settings_update(property_field: Dictionary) -> void:
	var property_control = property_scene_container.get_child(0) as PandoraPropertyControl
	property_control.update_field_settings(property_field)
	PandoraSettings.save_extensions_configurations()
	update_extensions_configurations.emit()

func _on_enabled(toggled_on: bool) -> void:
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	var extensions_configuration := extensions_configurations[_selected_extension_conf_index]
	var extension_property = extensions_configurations[_selected_extension_conf_index]["properties"][_selected_extension_property_index] as Dictionary
	extension_property["enabled"] = toggled_on
	
	if not toggled_on:
		ext_property_show_on_top_btn.disabled = true
		dependencies_container.modulate.a = 0.45
		customization_container.modulate.a = 0.45
	else:
		ext_property_show_on_top_btn.disabled = false
		dependencies_container.modulate.a = 1
		customization_container.modulate.a = 1
	
	PandoraSettings.save_extensions_configurations()
	update_extensions_configurations.emit()

func _on_show_on_top(toggled_on: bool) -> void:
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	var extensions_configuration := extensions_configurations[_selected_extension_conf_index]
	var extension_property = extensions_configurations[_selected_extension_conf_index]["properties"][_selected_extension_property_index] as Dictionary
	extension_property["show_on_top"] = toggled_on
	
	PandoraSettings.save_extensions_configurations()
	update_extensions_configurations.emit()

func _on_new_property_pressed() -> void:
	creation_dialog.popup_centered()

func _on_creation_dialog_confirmed() -> void:
	var property_name = creation_name_edit.text
	var property_type = creation_type_edit.text
	var property_description = creation_description_edit.text
	
	if not property_name:
		push_error("Property name is mandatory. Please retry.")
	if not property_type:
		push_error("Property type is mandatory. Please retry.")
	
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	var extensions_dirs = PandoraSettings.get_extensions_dirs()
	
	var extensions_dir = extensions_dirs[_selected_extension_conf_index]
	var extensions_configuration := extensions_configurations[_selected_extension_conf_index]
	
	var opened_ext_dir = DirAccess.open(extensions_dir)
	opened_ext_dir.make_dir_recursive(property_type + "/icons")
	opened_ext_dir.make_dir_recursive(property_type + "/model/types")
	opened_ext_dir.make_dir_recursive(property_type + "/property_button")
	opened_ext_dir.make_dir_recursive(property_type + "/ui_component")
	FileAccess.open(extensions_dir + "/" + property_type + "/model/" + property_type + ".gd", FileAccess.WRITE)
	FileAccess.open(extensions_dir + "/" + property_type + "/model/types/" + property_type + ".gd", FileAccess.WRITE)
	FileAccess.open(extensions_dir + "/" + property_type + "/ui_component/" + property_type + ".gd", FileAccess.WRITE)
	
	var ui_component := PandoraPropertyControl.new()
	ui_component.type = property_type
	
	var ui_component_scene := PackedScene.new()
	var result = ui_component_scene.pack(ui_component)
	if result == OK:
		ResourceSaver.save(ui_component_scene, extensions_dir + "/" + property_type + "/ui_component/" + property_type + ".tscn")
	
	var property_button := PandoraPropertyButton.new()
	property_button.scene = load(extensions_dir + "/" + property_type + "/ui_component/" + property_type + ".tscn")
	var property_button_scene := PackedScene.new()
	result = property_button_scene.pack(property_button)
	if result == OK:
		ResourceSaver.save(property_button_scene, extensions_dir + "/" + property_type + "/property_button/property_button.tscn")
	
	var extension_property : Dictionary = {
		"name": property_name,
		"dir_name": property_type,
		"description": property_description,
		"enabled": false,
		"show_on_top": true,
		"dependencies": []
	}
	extensions_configurations[_selected_extension_conf_index]["properties"].append(extension_property)
	PandoraSettings.save_extensions_configurations()
	update_extensions_configurations.emit()
	
	creation_name_edit.text = ""
	creation_type_edit.text = ""
	creation_description_edit.text = ""
	
	_load_configurations()

func _on_add_prop_dependency_pressed() -> void:
	dependency_type_edit.editable = true
	dependency_type_edit.text = "PROPERTY"
	dependency_type_edit.editable = false
	
	extensions_properties_selector.clear()
	
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	var extensions_configuration := extensions_configurations[_selected_extension_conf_index]
	for ext_conf_prop in extensions_configuration["properties"]:
		if ext_conf_prop["name"] != extensions_configuration["properties"][_selected_extension_property_index]["name"]:
			extensions_properties_selector.add_item(ext_conf_prop["name"])
	
	dependency_dialog.popup_centered()

func _on_add_entity_dependency_pressed() -> void:
	dependency_type_edit.editable = true
	dependency_type_edit.text = "ENTITY"
	dependency_type_edit.editable = false
	dependency_dialog.popup_centered()

func _on_dependency_dialog_confirmed() -> void:
	var property_name := extensions_properties_selector.get_item_text(extensions_properties_selector.selected)
	
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	var extensions_configuration := extensions_configurations[_selected_extension_conf_index]
	var extension_properties = extensions_configurations[_selected_extension_conf_index]["properties"]
	var selected_dependency = extension_properties.filter(func(property: Dictionary): return property["name"] == property_name)[0] as Dictionary
	if not selected_dependency["enabled"]:
		_selected_dependency = selected_dependency
		enable_dialog.popup_centered()
	else:
		extension_properties[_selected_extension_property_index]["dependencies"].append({"name": selected_dependency["name"], "type": "PROPERTY"})
		PandoraSettings.save_extensions_configurations()
		update_extensions_configurations.emit()

func _on_enable_dialog_confirmed() -> void:
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	var extensions_configuration := extensions_configurations[_selected_extension_conf_index]
	var extension_properties = extensions_configurations[_selected_extension_conf_index]["properties"]
	extension_properties.filter(func(property: Dictionary): return property["name"] == _selected_dependency["name"])[0]["enabled"] = true
	extension_properties[_selected_extension_property_index]["dependencies"].append({"name": _selected_dependency["name"], "type": "PROPERTY"})
	PandoraSettings.save_extensions_configurations()
	update_extensions_configurations.emit()

func _on_delete_property_pressed() -> void:
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	var extensions_configuration := extensions_configurations[_selected_extension_conf_index]
	var current_property_name = extensions_configuration["properties"][_selected_extension_property_index]["name"]
	var is_dependency = extensions_configuration["properties"].any(func(property: Dictionary): \
		return property["dependencies"].any(func(dep: Dictionary): \
			return dep["name"] == current_property_name))
	
	if is_dependency:
		dependency_check_alert.popup_centered()
	else:
		pass

func _on_dependency_removed(dep: Dictionary) -> void:
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	var extensions_configuration := extensions_configurations[_selected_extension_conf_index]
	var extension_properties = extensions_configurations[_selected_extension_conf_index]["properties"]
	var property_dependencies = extension_properties[_selected_extension_property_index]["dependencies"] as Array
	property_dependencies.erase(dep)
	
	PandoraSettings.save_extensions_configurations()
	update_extensions_configurations.emit()
