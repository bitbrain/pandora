extends PandoraPropertyType

const SERIALIZED_VALUES = "values"
const SERIALIZED_VALUES_TYPE = "values_type"

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
		if dict.has(SERIALIZED_VALUES) and dict.has(SERIALIZED_VALUES_TYPE):
			var values_type = PandoraPropertyType
			if not settings.is_empty():
				PandoraPropertyType.lookup(settings[SETTING_ARRAY_TYPE])
			else:
				values_type = PandoraPropertyType.lookup(dict[SERIALIZED_VALUES_TYPE])

			for i in range(dict[SERIALIZED_VALUES].size()):
				var value = dict[SERIALIZED_VALUES][str(i)]
				if not values_type is UndefinedType:
					array.append(values_type.parse_value(value))
				else:
					array.append(value)
		else:
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
	var dict = {
		SERIALIZED_VALUES: {},
		SERIALIZED_VALUES_TYPE: ""
	}
	if not array.is_empty():
		var types = PandoraPropertyType.get_all_types()
		var values_type : PandoraPropertyType
		for i in range(array.size()):
			var value = array[i]
			var found_valid_type = false
			for type in types:
				if type.is_valid(value):
					dict[SERIALIZED_VALUES][str(i)] = type.write_value(value)
					if values_type == null:
						values_type = type
					elif values_type != type:
						# Array contains mixed-type values
						values_type = UndefinedType.new()
					found_valid_type = true
					break
			if not found_valid_type:
				# Array contains a value for which no valid type could be found
				dict[SERIALIZED_VALUES][str(i)] = value
				values_type = UndefinedType.new()
		dict[SERIALIZED_VALUES_TYPE] = values_type.get_type_name()
	return dict

func allow_nesting() -> bool:
	return false
