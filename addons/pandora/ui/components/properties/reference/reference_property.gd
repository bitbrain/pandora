@tool
extends PandoraPropertyControl


@onready var entity_picker = $EntityPicker


func _ready() -> void:
	refresh()
	entity_picker.entity_selected.connect(
		func(entity:PandoraEntity):
			var reference = PandoraReference.new(entity.get_entity_id())
			_property.set_default_value(reference)
			property_value_changed.emit())


func refresh() -> void:
	if _property != null:
		entity_picker.set_filter(_get_setting("Category Filter") as String)
		entity_picker.categories_only = _get_setting("Category Mode") as bool
		var default_value = _property.get_default_value() as PandoraReference
		if default_value != null:
			var entity = default_value.get_entity()
			if entity != null:
				entity_picker.select(entity)



func get_default_settings() -> Dictionary:
	return {
		"Category Mode": {
			"type": "bool",
			"value": false
		},
		"Category Filter": {
			"type": "reference",
			"value": ""
		}
	}
	
