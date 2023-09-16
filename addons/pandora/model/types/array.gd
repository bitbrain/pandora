extends PandoraPropertyType

const ICON_PATH = "res://addons/pandora/icons/Array.svg"

const SETTING_ARRAY_TYPE = "Array Type"

const SETTINGS = {
	SETTING_ARRAY_TYPE: {
		"type": "property_type",
		"value": "string",
	}
}

func _init() -> void:
	super("array", SETTINGS, [], ICON_PATH)


func is_valid(variant:Variant) -> bool:
	return variant is Array

func get_merged_settings(property: PandoraProperty) -> Dictionary:
	var merged_settings: Dictionary = _settings.duplicate()
	var array_type = PandoraPropertyType.lookup(property.get_setting(SETTING_ARRAY_TYPE))
	var array_type_settings: Dictionary = array_type.get_settings().duplicate()
	merged_settings.merge(array_type_settings)
	return merged_settings


func parse_value(variant:Variant, settings:Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var array = []
		var dict = variant as Dictionary
		for i in range(dict.size()):
			var value = dict[str(i)]
			if not settings.is_empty():
				if settings[SETTING_ARRAY_TYPE] == "reference":
					value = PandoraReference.new(value["_entity_id"], value["_type"]).get_entity()
				if settings[SETTING_ARRAY_TYPE] == "resource":
					value = load(value)
				if settings[SETTING_ARRAY_TYPE] == "color":
					value = Color.from_string(value, Color.WHITE)
			array.append(value)
		return array
	return variant
	
func write_value(variant:Variant) -> Variant:
	var array = variant as Array
	var dict = {}
	if not array.is_empty():
		for i in range(array.size()):
			var value = array[i]
			if value is PandoraEntity:
				value = PandoraReference.new(value.get_entity_id(), PandoraReference.Type.CATEGORY if value is PandoraCategory else PandoraReference.Type.ENTITY).save_data()
			elif value is Resource:
				value = value.resource_path
			elif value is Color:
				value = value.to_html()
			
			if value != null:
				dict[str(i)] = value
	return dict

func allow_nesting() -> bool:
	return false
