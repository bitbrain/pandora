@tool
extends PanelContainer

signal item_removal_requested

var _property: PandoraProperty
var _control: PandoraPropertyControl:
	set(c):
		_control = c
		_refresh_value.call_deferred()
var _backend: PandoraEntityBackend

@onready var item_value: MarginContainer = %ItemValue
@onready var delete_item_button: Button = %DeleteItemButton
@onready var confirmation_dialog: ConfirmationDialog = %ConfirmationDialog


func init(
	property: PandoraProperty, control: PandoraPropertyControl, backend: PandoraEntityBackend
) -> void:
	if self._control != null:
		_control.queue_free()
	self._property = property
	self._control = control
	self._backend = backend


func _ready():
	delete_item_button.pressed.connect(func(): confirmation_dialog.popup())
	confirmation_dialog.confirmed.connect(_delete_item)
	_refresh.call_deferred()
	if _control != null:
		_control.property_value_changed.connect(_refresh)


func _refresh_value() -> void:
	for child in item_value.get_children():
		child.queue_free()
	item_value.get_children().clear()
	item_value.add_child(_control)


func _refresh(_value: Variant = null):
	if _control == null or _property == null:
		return
	_control.refresh()


func _delete_item():
	item_removal_requested.emit()
	queue_free()
