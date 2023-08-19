@tool
extends PandoraPropertyControl


const CATEGORY_FILTER = "Category Filter"
const CATEGORIES_ONLY = "Categories Only"
const SORT_LIST = "Sort List"

const SORT_ALPHABETICALLY = "Alphabetically"
const SORT_AS_IS = "As-Is"


@onready var entity_picker = $EntityPicker


func _ready() -> void:
	refresh()
	_property.setting_changed.connect(_setting_changed)
	_property.setting_cleared.connect(_setting_changed)
	entity_picker.focus_exited.connect(func(): unfocused.emit())
	entity_picker.focus_entered.connect(func(): focused.emit())
	entity_picker.entity_selected.connect(
		func(entity:PandoraEntity):
			var reference = PandoraReference.new(entity.get_entity_id(), 1 if entity is PandoraCategory else 0)
			_property.set_default_value(reference)
			property_value_changed.emit())


func refresh() -> void:
	if _property != null:
		entity_picker.set_filter(_get_setting(CATEGORY_FILTER) as String)
		entity_picker.categories_only = _get_setting(CATEGORIES_ONLY) as bool
		match _get_setting(SORT_LIST) as String:
			SORT_ALPHABETICALLY:
				entity_picker.set_sort(func(a,b): return a.get_entity_name() < b.get_entity_name())
			SORT_AS_IS:
				entity_picker.set_sort(func(a,b): return false)
		var entity = _property.get_default_value() as PandoraEntity
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
		},
		SORT_LIST: {
			"type": "string",
			"options": [
				SORT_ALPHABETICALLY,
				SORT_AS_IS
			],
			"value": SORT_ALPHABETICALLY
		}
	}
	
	
func _setting_changed(key:String) -> void:
	if key == CATEGORIES_ONLY || key == CATEGORY_FILTER || key == SORT_LIST:
		refresh()
