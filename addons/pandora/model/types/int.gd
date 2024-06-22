extends PandoraPropertyType

const ICON_PATH = "res://addons/pandora/icons/int.svg"

const SETTING_MIN_VALUE = "Min Value"
const SETTING_MAX_VALUE = "Max Value"

const SETTINGS = {
	SETTING_MIN_VALUE: {"type": "int", "value": -9999999999},
	SETTING_MAX_VALUE: {"type": "int", "value": 9999999999}
}


func _init() -> void:
	super("int", SETTINGS, 0, ICON_PATH)


func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is float:
		return int(variant)
	return variant


func is_valid(variant: Variant) -> bool:
	return variant is int
