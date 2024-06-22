extends PandoraPropertyType

const ICON_PATH = "res://addons/pandora/icons/AtlasTexture.svg"

const SETTINGS = {}


func _init() -> void:
	super("resource", SETTINGS, null, ICON_PATH)


func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is String:
		return load(variant)
	return variant


func write_value(variant: Variant) -> Variant:
	if variant is Resource:
		return variant.resource_path
	return variant


func is_valid(variant: Variant) -> bool:
	return variant is Resource
