extends PandoraPropertyType

const SETTING_MIN_VALUE = "Min Quantity"
const SETTING_MAX_VALUE = "Max Quantity"
var SETTINGS = {
	SETTING_MIN_VALUE: {"type": "int", "value": -9999999999},
	SETTING_MAX_VALUE: {"type": "int", "value": 9999999999}
}

func _init() -> void:
	super("test_property", SETTINGS, null, "res://pandora/extensions/test_property/icons/icon.png")
	Pandora.update_fields_settings.connect(_on_update_fields_settings)
	_update_fields_settings()

func _on_update_fields_settings(type: String) -> void:
	if _type_name == type:
		_update_fields_settings()

func _update_fields_settings() -> void:
	var extension_configuration := PandoraSettings.find_extension_configuration_property("test_property")
	var fields_settings := extension_configuration["fields"] as Array
	for field_settings in fields_settings:
		if field_settings["name"] == "Quantity":
			if field_settings["enabled"] == false:
				SETTINGS.erase(SETTING_MAX_VALUE)
				SETTINGS.erase(SETTING_MIN_VALUE)
			else:
				if !SETTINGS.has(SETTING_MAX_VALUE) or !SETTINGS.has(SETTING_MIN_VALUE):
					SETTINGS[SETTING_MAX_VALUE] = {"type": "int", "value": field_settings["settings"]["max_value"]}
					SETTINGS[SETTING_MIN_VALUE] = {"type": "int", "value": field_settings["settings"]["min_value"]}
	_settings = SETTINGS

func parse_value(variant: Variant, _s: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var item_name = "" if not variant.has("item_name") else variant["item_name"]
		var quantity = 0 if not variant.has("quantity") else variant["quantity"]
		return PandoraTestProperty.new(item_name, quantity)
	return variant

func write_value(variant: Variant) -> Variant:
	if variant is PandoraTestProperty:
		var extension_configuration := PandoraSettings.find_extension_configuration_property("test_property")
		var fields_settings := extension_configuration["fields"] as Array
		return variant.save_data(fields_settings)
	return variant

func is_valid(variant: Variant) -> bool:
	return variant is PandoraTestProperty
