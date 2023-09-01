extends PandoraPropertyType


const SETTINGS = {}


func _init() -> void:
	super("string", SETTINGS, "")


func is_valid(variant:Variant) -> bool:
	return variant is String
