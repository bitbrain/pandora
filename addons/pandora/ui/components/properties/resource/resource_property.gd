@tool
extends PandoraPropertyControl


@onready var resource_picker = $ResourcePicker


func _ready() -> void:
	refresh()
	resource_picker.focus_exited.connect(func(): unfocused.emit())
	resource_picker.focus_entered.connect(func(): focused.emit())
	resource_picker.resource_changed.connect(
		func(resource_path:String):
			_property.set_default_value(load(resource_path))
			property_value_changed.emit(resource_path))


func refresh() -> void:
	if _property != null:
		var default_value = _property.get_default_value() as Resource
		if default_value != null:
			resource_picker.set_resource_path(default_value.resource_path)
