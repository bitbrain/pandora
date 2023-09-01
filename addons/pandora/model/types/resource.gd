extends PandoraPropertyType


const SETTINGS = {}


func _init() -> void:
	super("resource", SETTINGS, null)


func parse_value(variant:Variant) -> Variant:
	if variant is String:
		return load(variant)
	return variant
	
	
func write_value(variant:Variant) -> Variant:
	if variant is Resource:
		return variant.resource_path
	return variant


func is_valid(variant:Variant) -> bool:
	return variant is Resource
