extends PandoraPropertyType


const SETTINGS = {}


func _init() -> void:
	super("bool", SETTINGS, false)


func is_valid(variant:Variant) -> bool:
	return variant is bool
