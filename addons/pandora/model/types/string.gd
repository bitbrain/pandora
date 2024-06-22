extends PandoraPropertyType

const ICON_PATH = "res://addons/pandora/icons/String.svg"

const SETTINGS = {}


func _init() -> void:
	super("string", SETTINGS, "", ICON_PATH)


func is_valid(variant: Variant) -> bool:
	return variant is String
