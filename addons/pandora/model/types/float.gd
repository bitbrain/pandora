extends PandoraPropertyType

const ICON_PATH = "res://addons/pandora/icons/float.svg"

const SETTING_MIN_VALUE = "Min Value"
const SETTING_MAX_VALUE = "Max Value"
const SETTING_STEPS = "Steps"

const SETTINGS = {
	SETTING_STEPS: {"type": "float", "value": 0.01},
	SETTING_MIN_VALUE: {"type": "int", "value": -9999999999},
	SETTING_MAX_VALUE: {"type": "int", "value": 9999999999}
}


func _init() -> void:
	super("float", SETTINGS, 0.0, ICON_PATH)


func is_valid(variant: Variant) -> bool:
	return variant is float
