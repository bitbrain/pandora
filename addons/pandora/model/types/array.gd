extends PandoraPropertyType

const SETTING_ARRAY_TYPE = "Array Type"
const ACCEPTED_TYPES = [
	"String",
	"Int",
	"Float",
	"Bool",
	"Color",
	"Reference",
	"Resource"
]

const SETTINGS = {
	SETTING_ARRAY_TYPE: {
		"type": "string",
		"options": ACCEPTED_TYPES,
		"value": ACCEPTED_TYPES[0]
	}
}


func _init() -> void:
	super("array", SETTINGS, false)


func is_valid(variant:Variant) -> bool:
	return variant is Array
