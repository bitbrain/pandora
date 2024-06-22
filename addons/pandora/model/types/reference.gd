extends PandoraPropertyType

const ICON_PATH = "res://addons/pandora/icons/Object.svg"

const SETTING_CATEGORIES_ONLY = "Categories Only"
const SETTING_CATEGORY_FILTER = "Category Filter"
const SETTING_SORT_LIST = "Sort List"
const SORT_ALPHABETICALLY = "Alphabetically"
const SORT_AS_IS = "As-Is"

const SETTINGS = {
	SETTING_CATEGORIES_ONLY: {"type": "bool", "value": false},
	SETTING_CATEGORY_FILTER: {"type": "reference", "value": ""},
	SETTING_SORT_LIST:
	{"type": "string", "options": [SORT_ALPHABETICALLY, SORT_AS_IS], "value": SORT_ALPHABETICALLY}
}


func _init() -> void:
	super("reference", SETTINGS, null, ICON_PATH)


func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var reference = PandoraReference.new("", 0)
		reference.load_data(variant)
		return reference
	return variant


func write_value(variant: Variant) -> Variant:
	if variant is PandoraReference:
		return variant.save_data()
	return variant


func is_valid(variant: Variant) -> bool:
	return variant is PandoraEntity
