extends PandoraPropertyType

const ICON_PATH = "res://addons/pandora/icons/Array.svg"

const SETTING_ARRAY_TYPE = "Array Type"

const SETTINGS = {
	SETTING_ARRAY_TYPE:
	{
		"type": "property_type",
		"value": "string",
	}
}


func _init() -> void:
	super("array", SETTINGS, [], ICON_PATH)


func is_valid(variant: Variant) -> bool:
	return variant is Array


func get_merged_settings(property: PandoraProperty) -> Dictionary:
	var merged_settings: Dictionary = _settings.duplicate()
	var array_type = PandoraPropertyType.lookup(property.get_setting(SETTING_ARRAY_TYPE))
	var array_type_settings: Dictionary = array_type.get_settings().duplicate()
	merged_settings.merge(array_type_settings)
	return merged_settings


func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var array = []
		var dict = variant as Dictionary
		for i in range(dict.size()):
			var value = dict[str(i)]
			if not settings.is_empty():
				if settings[SETTING_ARRAY_TYPE] == "reference" and "_entity_id" in value:
					value = PandoraReference.new(value["_entity_id"], value["_type"]).get_entity()
				if settings[SETTING_ARRAY_TYPE] == "resource":
					value = load(value)
				if settings[SETTING_ARRAY_TYPE] == "color":
					value = Color.from_string(value, Color.WHITE)
			else:
				if value is Dictionary and value.has("type") and value.has("value"):
					var value_type = value["type"]
					var dict_value = value["value"]

					var type = PandoraPropertyType.lookup(value_type)
					if type != null:
						value = type.parse_value(dict_value)

			array.append(value)
		return array
	return variant


func write_value(variant: Variant) -> Variant:
	var array = variant as Array
	var dict = {}
	if not array.is_empty():
		var types = PandoraPropertyType.get_all_types()
		var value_type

		for i in range(array.size()):
			var value = array[i]
			if value is PandoraEntity:
				value_type = PandoraPropertyType.lookup("reference")
				value = (
					PandoraReference
					. new(
						value.get_entity_id(),
						(
							PandoraReference.Type.CATEGORY
							if value is PandoraCategory
							else PandoraReference.Type.ENTITY
						)
					)
					. save_data()
				)
			elif value is PandoraReference:
				value_type = PandoraPropertyType.lookup("reference")
				value = value.save_data()
			else:
				for type in types:
					if type.is_valid(value):
						value_type = type
						value = type.write_value(value)
						break

			if value != null:
				if value_type == null:
					dict[str(i)] = value
				else:
					dict[str(i)] = {"type": value_type.get_type_name(), "value": value}

	return dict


func allow_nesting() -> bool:
	return false
