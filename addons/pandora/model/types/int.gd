extends PandoraPropertyType


const SETTING_MIN_VALUE = "Min Value"
const SETTING_MAX_VALUE = "Max Value"


const SETTINGS = {
		SETTING_MIN_VALUE: {
			"type": "int",
			"value": -9999999999
		},
		SETTING_MAX_VALUE: {
			"type": "int",
			"value": 9999999999
		}
	}


func _init() -> void:
	super("int", SETTINGS, 0)


func parse_value(variant:Variant) -> Variant:
	if variant is float:
		return int(variant)
	return variant


func is_valid(variant:Variant) -> bool:
	return variant is int
