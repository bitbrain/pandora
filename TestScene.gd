extends CenterContainer


func _ready() -> void:
	var copper_ore = Pandora.get_entity(Ores.COPPER_ORE) as Item
	print(copper_ore.get_entity_name())
	
	var copper_instance = copper_ore.instantiate()
	
	print(copper_instance.get_string("Description"))
	
	print(copper_ore.get_rarity())
