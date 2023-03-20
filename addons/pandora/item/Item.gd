class_name Item extends RefCounted

@export var id:String
@export var name:String

var traits:Array[Trait]

func create_new_item() -> Item:
	return null
	
func get_traits() -> Array[Trait]:
	return traits
