@tool
extends PandoraPropertyControl


const CATEGORY_FILTER = "Category Filter"
const CATEGORIES_ONLY = "Categories Only"


@onready var entity_picker = $EntityPicker


func _ready() -> void:
	refresh()
	_property.setting_changed.connect(_setting_changed)
	_property.setting_cleared.connect(_setting_changed)
	entity_picker.entity_selected.connect(
		func(entity:PandoraEntity):
			var reference = PandoraReference.new(entity.get_entity_id(), 1 if entity is PandoraCategory else 0)
			_property.set_default_value(reference)
			property_value_changed.emit())


func refresh() -> void:
	if _property != null:
		entity_picker.set_filter(_get_setting(CATEGORY_FILTER) as String)
		entity_picker.categories_only = _get_setting(CATEGORIES_ONLY) as bool
		var default_value = _property.get_default_value() as PandoraReference
		if default_value != null:
			var entity = default_value.get_entity()
			if entity != null:
				entity_picker.select.call_deferred(entity)



func get_default_settings() -> Dictionary:
	return {
		CATEGORIES_ONLY: {
			"type": "bool",
			"value": false
		},
		CATEGORY_FILTER: {
			"type": "reference",
			"value": ""
		}
	}
	
	
func _setting_changed(key:String) -> void:
	if key == CATEGORIES_ONLY || key == CATEGORY_FILTER:
		_property.set_default_value(null)
		refresh()
