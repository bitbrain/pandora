extends PandoraPropertyType

const SETTING_CATEGORY_FILTER = "Category Filter"
const SETTING_MIN_VALUE = "Min Quantity"
const SETTING_MAX_VALUE = "Max Quantity"
const SETTINGS = {
	SETTING_MIN_VALUE: {"type": "int", "value": -9999999999},
	SETTING_MAX_VALUE: {"type": "int", "value": 9999999999}
}

func _init() -> void:
	super("dependency_property", SETTINGS, null, "res://pandora/extensions/test_property/icons/icon.png")

func parse_value(variant: Variant, _s: Dictionary = {}) -> Variant:
	if variant is Dictionary:
		var item_name = variant["item_name"]
		var quantity = variant["quantity"]
		return PandoraTestProperty.new(item_name, quantity)
	return variant

func write_value(variant: Variant) -> Variant:
	if variant is PandoraTestProperty:
		return variant.save_data()
	return variant

func is_valid(variant: Variant) -> bool:
	return variant is PandoraDependencyProperty
