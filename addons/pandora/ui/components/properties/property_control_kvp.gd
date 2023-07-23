@tool
extends PanelContainer


signal original_property_selected(category_id:String, property_name:String)


var _property:PandoraProperty:
	set(p):
		_property = p
		_refresh_key.call_deferred()
var _control:PandoraPropertyControl:
	set(c):
		_control = c
		_refresh_value.call_deferred()
var _backend:PandoraEntityBackend


@onready var property_key: LinkButton = %PropertyKey
@onready var property_key_edit: LineEdit = %PropertyKeyEdit
@onready var property_value: MarginContainer = %PropertyValue
@onready var reset_button: Button = %ResetButton
@onready var delete_property_button: Button = %DeletePropertyButton


func init(property:PandoraProperty, control:PandoraPropertyControl, backend:PandoraEntityBackend) -> void:
	self._property = property
	self._control = control
	self._backend = backend
	
	
func _ready() -> void:
	property_key_edit.text_changed.connect(_property_name_changed)
	reset_button.pressed.connect(_property_reset_to_default)
	delete_property_button.pressed.connect(_delete_property)
	_refresh.call_deferred()
	if _property != null:
		_set_edit_name_mode(_property.is_original())
		property_key.pressed.connect(func():
			original_property_selected.emit(_property.get_original_category_id(), _property.get_property_name()))
	if _control != null:
		_control.property_value_changed.connect(_refresh)


func edit_key():
	if property_key_edit.visible:
		property_key_edit.grab_focus()
	

func _refresh_key() -> void:
	property_key.text = _property.get_property_name()
	property_key_edit.text = _property.get_property_name()


func _refresh_value() -> void:
	property_value.get_children().clear()
	property_value.add_child(_control)


func _set_edit_name_mode(edit_mode:bool) -> void:
	property_key.visible = not edit_mode
	property_key_edit.visible = edit_mode
	
	
func _property_name_changed(new_name:String) -> void:
	# FIXME avoid key duplication issue
	_property._name = new_name


func _property_reset_to_default() -> void:
	_property.reset_to_default()
	_refresh()


func _refresh() -> void:
	if _control == null or _property == null:
		return
	_control.refresh()
	reset_button.visible = not _property.is_original() and _property.is_overridden()
	delete_property_button.disabled =  not _property.is_original()
	delete_property_button.tooltip_text = "Inherited property cannot be deleted" if delete_property_button.disabled else "Delete property"


func _delete_property() -> void:
	_backend.delete_property(_property)
	queue_free()
