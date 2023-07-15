@tool
extends PanelContainer


var _property:PandoraProperty:
	set(p):
		_property = p
		_refresh_key.call_deferred()
var _control:PandoraPropertyControl:
	set(c):
		_control = c
		_refresh_value.call_deferred()


@onready var property_key: Label = %PropertyKey
@onready var property_key_edit: LineEdit = %PropertyKeyEdit
@onready var property_value: MarginContainer = %PropertyValue
@onready var reset_button: Button = %ResetButton


func init(property:PandoraProperty, control:PandoraPropertyControl) -> void:
	self._property = property
	self._control = control
	
	
func _ready() -> void:
	property_key_edit.text_changed.connect(_property_name_changed)
	reset_button.pressed.connect(_property_reset_to_default)
	_refresh.call_deferred()
	if _property != null:
		_set_edit_name_mode(_property.is_original())
	if _control != null:
		_control.property_value_changed.connect(_refresh)


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
	_control.refresh()
	reset_button.visible = not _property.is_original() and _property.is_overridden()
