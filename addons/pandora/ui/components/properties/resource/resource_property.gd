@tool
extends PandoraPropertyControl


@onready var resource_picker = $ResourcePicker


func _ready() -> void:
	refresh()
	resource_picker.focus_exited.connect(func(): unfocused.emit())
	resource_picker.focus_entered.connect(func(): focused.emit())
	resource_picker.resource_changed.connect(
		func(resource_path:String):
			# Store the path as string, not the loaded resource
			# The type system will handle conversion via parse_value/write_value
			_property.set_default_value(resource_path)
			refresh()
			property_value_changed.emit(resource_path))


func refresh() -> void:
	if _property != null:
		# Get the raw value from overrides to avoid parse_value conversion
		var raw_value = null
		if _property is PandoraEntity.OverridingProperty:
			var prop_name = _property.get_property_name()
			if _property._parent_entity._property_overrides.has(prop_name):
				raw_value = _property._parent_entity._property_overrides[prop_name]

		if raw_value == null:
			raw_value = _property.get_default_value()

		# Handle both String paths and Resource objects
		if raw_value is String and raw_value != "":
			resource_picker.set_resource_path(raw_value)
		elif raw_value is Resource and raw_value.resource_path != "":
			resource_picker.set_resource_path(raw_value.resource_path)
		else:
			resource_picker.set_resource_path("")
