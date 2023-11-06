extends PandoraPropertyType

const ICON_PATH = "../../icons/String.svg"

const SETTINGS = {}


func _init() -> void:
	super("string", SETTINGS, "", ICON_PATH)


func is_valid(variant:Variant) -> bool:
	return variant is String
