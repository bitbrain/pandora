@tool
extends PandoraPropertyControl

var picker = EditorResourcePicker.new()


func _ready():
	picker.base_type = "Texture2D"
	picker.size = Vector2(470, 45)
	picker.resource_changed.connect(_on_resource_changed)
	picker.resource_selected.connect(_on_resource_selected)
	add_child(picker)
	refresh()


func _on_resource_changed(resource: Resource):
	var new_resource = resource.duplicate()
	_property.set_default_value(new_resource)
	property_value_changed.emit(new_resource)


func _on_resource_selected(resource: Resource, _inspect: bool):
	var new_resource = resource.duplicate()
	_property.set_default_value(new_resource)
	property_value_changed.emit(new_resource)


func refresh() -> void:
	if _property != null:
		var value = _property.get_default_value()
		picker.edited_resource = value
