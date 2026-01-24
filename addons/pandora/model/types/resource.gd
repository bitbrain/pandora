extends PandoraPropertyType

const ICON_PATH = "res://addons/pandora/icons/AtlasTexture.svg"

const SETTINGS = {}


func _init() -> void:
	super("resource", SETTINGS, null, ICON_PATH)


func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is String:
		# Handle empty strings as null to avoid "res://" loading errors
		if variant == "":
			return null
		# Load the resource and handle potential errors
		var resource = load(variant)
		if resource == null:
			push_warning("Failed to load resource: " + variant)
		return resource
	return variant


func write_value(variant: Variant) -> Variant:
	if variant == null:
		return null
	if variant is Resource:
		return variant.resource_path
	return variant


func is_valid(variant: Variant) -> bool:
	# Allow null as valid value for optional resources
	# Allow String (resource paths) as they will be converted to Resources
	# Allow Resource objects directly
	return variant == null or variant is Resource or variant is String
