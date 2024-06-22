extends PandoraPropertyType

const ICON_PATH = "res://addons/pandora/icons/Vector2i.svg"

const SETTING_MIN_COMPONENT_VALUE = "Min Component Value"
const SETTING_MAX_COMPONENT_VALUE = "Max Component Value"

const SETTINGS = {
	SETTING_MIN_COMPONENT_VALUE: {"type": "int", "value": -9999999999},
	SETTING_MAX_COMPONENT_VALUE: {"type": "int", "value": 9999999999}
}


func _init() -> void:
	super("vector2i", SETTINGS, Vector2i.ZERO, ICON_PATH)


func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is String:
		var values = variant.trim_prefix("(").trim_suffix(")").split(",", false, 1)
		return Vector2i(values[0].to_int(), values[1].to_int())
	return variant


func write_value(variant: Variant) -> Variant:
	var vector = variant as Vector2i
	return "(%s,%s)" % [vector.x, vector.y]


func is_valid(variant: Variant) -> bool:
	return variant is Vector2i
