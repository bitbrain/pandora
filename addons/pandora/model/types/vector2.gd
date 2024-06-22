extends PandoraPropertyType

const ICON_PATH = "res://addons/pandora/icons/Vector2.svg"

const SETTING_MIN_COMPONENT_VALUE = "Min Component Value"
const SETTING_MAX_COMPONENT_VALUE = "Max Component Value"
const SETTING_STEPS = "Steps"

const SETTINGS = {
	SETTING_STEPS: {"type": "float", "value": 0.01},
	SETTING_MIN_COMPONENT_VALUE: {"type": "int", "value": -9999999999},
	SETTING_MAX_COMPONENT_VALUE: {"type": "int", "value": 9999999999}
}


func _init() -> void:
	super("vector2", SETTINGS, Vector2.ZERO, ICON_PATH)


func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is String:
		var values = variant.trim_prefix("(").trim_suffix(")").split(",", false, 1)
		return Vector2(values[0].to_float(), values[1].to_float())
	return variant


func write_value(variant: Variant) -> Variant:
	var vector = variant as Vector2
	return "(%s,%s)" % [vector.x, vector.y]


func is_valid(variant: Variant) -> bool:
	return variant is Vector2
