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


func init(property:PandoraProperty, control:PandoraPropertyControl) -> void:
	self._property = property
	self._control = control
	
	
func _ready() -> void:
	_set_edit_name_mode(_property.is_original())
	property_key_edit.text_changed.connect(_property_name_changed)


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
