extends Node

func get_item_by_id(id:String) -> Item:
	return null

func get_item_blueprint_by_id(id:String) -> ItemBlueprint:
	return null
	
func get_inventory_by_id(id:String) -> Inventory:
	return null
	
func create_item(blueprintId:String, traits:Array[Trait] = []) -> Item:
	return null
	
func create_inventory(traits:Array[Trait] = []) -> Inventory:
	return null
	
func save_blueprint(blueprint:ItemBlueprint) -> ItemBlueprint:
	return blueprint
