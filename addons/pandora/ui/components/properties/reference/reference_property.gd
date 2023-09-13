@tool
extends PandoraPropertyControl


const ReferenceType = preload("res://addons/pandora/model/types/reference.gd")


@onready var entity_picker = $EntityPicker


func _ready() -> void:
	refresh()
	_property.setting_changed.connect(_setting_changed)
	_property.setting_cleared.connect(_setting_changed)
	entity_picker.focus_exited.connect(func(): unfocused.emit())
	entity_picker.focus_entered.connect(func(): focused.emit())
	entity_picker.entity_selected.connect(
		func(entity:PandoraEntity):
			_property.set_default_value(entity)
			property_value_changed.emit(entity))


func refresh() -> void:
	if _property != null:
		entity_picker.set_filter(_property.get_setting(ReferenceType.SETTING_CATEGORY_FILTER) as String)
		entity_picker.categories_only = _property.get_setting(ReferenceType.SETTING_CATEGORIES_ONLY) as bool
		match _property.get_setting(ReferenceType.SETTING_SORT_LIST) as String:
			ReferenceType.SORT_ALPHABETICALLY:
				entity_picker.set_sort(func(a,b): return a.get_entity_name() < b.get_entity_name())
			ReferenceType.SORT_AS_IS:
				entity_picker.set_sort(func(a,b): return false)
		var entity = _property.get_default_value() as PandoraEntity
		if entity != null:
			entity_picker.select.call_deferred(entity)
	
	
func _setting_changed(key:String) -> void:
	if key == ReferenceType.SETTING_CATEGORIES_ONLY || key == ReferenceType.SETTING_CATEGORY_FILTER || key == ReferenceType.SETTING_SORT_LIST:
		refresh()
