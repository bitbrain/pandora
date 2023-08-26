@tool
class_name Rarity extends PandoraEntity


func get_rarity_color() -> Color:
	return get_entity_property("Rarity Color").get_default_value() as Color
