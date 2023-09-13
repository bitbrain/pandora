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
