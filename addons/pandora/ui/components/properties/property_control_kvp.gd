@tool
extends PanelContainer

## invoked when a property was selected that is inherited.
signal inherited_property_selected(category_id: String, property_name: String)

## called when an original property was selected
signal original_property_selected(property: PandoraProperty)

var _property: PandoraProperty:
	set(p):
		_property = p
		_refresh_key.call_deferred()
var _control: PandoraPropertyControl:
	set(c):
		_control = c
		_refresh_value.call_deferred()
var _backend: PandoraEntityBackend

@onready var property_key: LinkButton = %PropertyKey
@onready var property_key_edit: LineEdit = %PropertyKeyEdit
@onready var property_value: MarginContainer = %PropertyValue
@onready var reset_button: Button = %ResetButton
@onready var regenerate_id_button: Button = %RegenerateIDButton
@onready var delete_property_button: Button = %DeletePropertyButton
@onready var confirmation_dialog = %ConfirmationDialog


func init(
	property: PandoraProperty, control: PandoraPropertyControl, backend: PandoraEntityBackend
) -> void:
	if self._control != null:
		_control.queue_free()
	self._property = property
	self._control = control
	self._backend = backend


func _ready() -> void:
	property_key_edit.focus_entered.connect(_property_key_focused)
	property_key_edit.text_changed.connect(_property_name_changed)
	reset_button.pressed.connect(_property_reset_to_default)
	regenerate_id_button.pressed.connect(func(): Pandora.regenerate_property_id(_property))
	delete_property_button.pressed.connect(func(): confirmation_dialog.popup())
	confirmation_dialog.confirmed.connect(_delete_property)
	_refresh.call_deferred()
	if _property != null:
		_set_edit_name_mode(_property.is_original())
		property_key.pressed.connect(
			func(): inherited_property_selected.emit(
				_property.get_original_category_id(), _property.get_property_name()
			)
		)
	if _control != null:
		_control.property_value_changed.connect(_refresh)


func edit_key():
	if property_key_edit.visible:
		property_key_edit.grab_focus()


func _refresh_key() -> void:
	property_key.text = _property.get_property_name()
	property_key_edit.text = _property.get_property_name()


func _refresh_value() -> void:
	for child in property_value.get_children():
		child.queue_free()
	property_value.get_children().clear()
	property_value.add_child(_control)


func _set_edit_name_mode(edit_mode: bool) -> void:
	property_key.visible = not edit_mode
	property_key_edit.visible = edit_mode


func _property_name_changed(new_name: String) -> void:
	# FIXME avoid key duplication issue
	_property._name = new_name


func _property_reset_to_default() -> void:
	_property.reset_to_default()
	_refresh()


func _refresh(_value: Variant = null) -> void:
	if _control == null or _property == null:
		return
	# FIXME: focused & unfocused signals don't quite work!
	if not _control.unfocused.is_connected(_control_value_unfocused):
		_control.unfocused.connect(_control_value_unfocused)
	if not _control.focused.is_connected(_control_value_focused):
		_control.focused.connect(_control_value_focused)
	_control.refresh()
	reset_button.visible = not _property.is_original() and _property.is_overridden()
	regenerate_id_button.disabled = not _property.is_original()
	regenerate_id_button.visible = _property.is_original()
	if regenerate_id_button.disabled:
		regenerate_id_button.tooltip_text = "Inherited property id cannot be regenerated"
	else:
		regenerate_id_button.tooltip_text = "Regenerate property id"
	delete_property_button.disabled = not _property.is_original()
	delete_property_button.visible = _property.is_original()
	if delete_property_button.disabled:
		delete_property_button.tooltip_text = "Inherited property cannot be deleted"
	else:
		delete_property_button.tooltip_text = "Delete property"


func _delete_property() -> void:
	_backend.delete_property(_property)
	queue_free()


func _property_key_focused() -> void:
	original_property_selected.emit(_property)


func _property_key_unfocused() -> void:
	pass


func _control_value_focused() -> void:
	if property_key_edit.visible:
		original_property_selected.emit(_property)


func _control_value_unfocused() -> void:
	pass
