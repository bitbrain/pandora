extends PandoraPropertyType

const ICON_PATH = "res://addons/pandora/icons/bool.svg"

const SETTINGS = {}


func _init() -> void:
	super("bool", SETTINGS, false, ICON_PATH)


func is_valid(variant: Variant) -> bool:
	return variant is bool
