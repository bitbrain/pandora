@tool
class_name Item extends PandoraEntity


func get_rarity() -> Rarity:
	return get_reference("Rarity") as Rarity


func get_maximum_stack_size() -> int:
	return get_integer("Maximum Stack Size")
