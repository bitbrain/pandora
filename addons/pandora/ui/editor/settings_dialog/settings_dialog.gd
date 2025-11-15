@tool
extends Control

signal update_extensions_configurations

@onready var window: Window = $Window
@onready var extensions_list: ItemList = $Window/PanelContainer/HBoxContainer/ExtensionsContainer/ItemList
@onready var extension_label: Label = $Window/PanelContainer/HBoxContainer/VBoxContainer/Label
@onready var select_extension_label: Label = $Window/PanelContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/SelectExtension
@onready var no_properties_label: Label = $Window/PanelContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/NoProperties
@onready var ext_configuration_container: VBoxContainer = $Window/PanelContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer

@onready var ext_properties_list: ItemList = $Window/PanelContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/Properties/ItemList
@onready var ext_property_desc: Label = $Window/PanelContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/Label
@onready var ext_property_enable_btn: CheckButton = $Window/PanelContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/CheckButton
@onready var ext_property_show_on_top_btn: CheckButton = $Window/PanelContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/CheckButton2
@onready var properties_dependencies: VBoxContainer = $Window/PanelContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/PropertiesDependencies
@onready var entities_dependencies: VBoxContainer = $Window/PanelContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/EntitiesDependencies
@onready var properties_dependencies_container: GridContainer = $Window/PanelContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/PropertiesDependencies/GridContainer
@onready var entities_dependencies_container: GridContainer = $Window/PanelContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/EntitiesDependencies/GridContainer
@onready var ext_property_details: VBoxContainer = $Window/PanelContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer

@onready var creation_dialog: ConfirmationDialog = $Window/CreationDialog
@onready var creation_name_edit: LineEdit = $Window/CreationDialog/VBoxContainer/HBoxContainer/VBoxContainer/LineEdit
@onready var creation_type_edit: LineEdit = $Window/CreationDialog/VBoxContainer/HBoxContainer/VBoxContainer2/LineEdit2
@onready var creation_description_edit: TextEdit = $Window/CreationDialog/VBoxContainer/VBoxContainer/TextEdit

var _selected_extension_conf_index : int
var _selected_extension_property_index : int

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
	
	select_extension_label.hide()
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
	
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	var extensions_configuration := extensions_configurations[_selected_extension_conf_index]
	var extension_property = extensions_configurations[_selected_extension_conf_index]["properties"][index] as Dictionary
	
	ext_property_desc.text = extension_property["description"]
	ext_property_enable_btn.button_pressed = extension_property["enabled"]
	ext_property_show_on_top_btn.button_pressed = extension_property["show_on_top"]
	if not extension_property["dependencies"]:
		properties_dependencies.hide()
		entities_dependencies.hide()
	else:
		var dependencies : Array[Dictionary] = extension_property["dependencies"]
		var property_dependencies := dependencies.filter(func(dep: Dictionary): return dep["type"] == "PROPERTY")
		var model_dependencies := dependencies.filter(func(dep: Dictionary): return dep["type"] == "MODEL")
		if property_dependencies:
			for dep in property_dependencies:
				var dep_label = Label.new()
				dep_label.text = dep["name"]
				properties_dependencies_container.add_child(dep_label)
			properties_dependencies.show()
		if model_dependencies:
			for dep in model_dependencies:
				var dep_label = Label.new()
				dep_label.text = dep["name"]
				entities_dependencies_container.add_child(dep_label)
			entities_dependencies.show()
	
	if not extension_property["enabled"]:
		ext_property_show_on_top_btn.disabled = true
		properties_dependencies.modulate.a = 0.45
		entities_dependencies.modulate.a = 0.45
	else:
		ext_property_show_on_top_btn.disabled = false
		properties_dependencies.modulate.a = 1
		entities_dependencies.modulate.a = 1
	ext_property_details.show()

func _on_enabled(toggled_on: bool) -> void:
	var extensions_configurations := PandoraSettings.get_extensions_configurations()
	var extensions_configuration := extensions_configurations[_selected_extension_conf_index]
	var extension_property = extensions_configurations[_selected_extension_conf_index]["properties"][_selected_extension_property_index] as Dictionary
	extension_property["enabled"] = toggled_on
	
	if not toggled_on:
		ext_property_show_on_top_btn.disabled = true
		properties_dependencies.modulate.a = 0.45
		entities_dependencies.modulate.a = 0.45
	else:
		ext_property_show_on_top_btn.disabled = false
		properties_dependencies.modulate.a = 1
		entities_dependencies.modulate.a = 1
	
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
	FileAccess.open(extensions_dir + "/" + property_type + "/property_button/property_button.tscn", FileAccess.WRITE)
	FileAccess.open(extensions_dir + "/" + property_type + "/ui_component/" + property_type + ".gd", FileAccess.WRITE)
	FileAccess.open(extensions_dir + "/" + property_type + "/ui_component/" + property_type + ".tscn", FileAccess.WRITE)
	
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
