class_name PandoraEntityInstanceBackend extends RefCounted

const id_generator = preload("res://addons/pandora/utils/id_generator.gd")


var _instances:Dictionary = {}
	
	
func create_entity_instance(of_entity:PandoraEntity) -> PandoraEntityInstance:
	var entity_instance = PandoraEntityInstance.new(id_generator.generate(), of_entity.get_entity_id(), _create_properties(of_entity))
	_instances[entity_instance._id] = entity_instance
	return entity_instance
	
	
func get_entity_instance(instance_id:String) -> PandoraEntityInstance:
	if not _instances.has(instance_id):
		return null
	return _instances[instance_id]
	
	
func delete_entity_instance(instance_id:String) -> bool:
	if not _instances.has(instance_id):
		return false
	_instances.erase(instance_id)
	return true
	
	
func load_data(data:Dictionary) -> void:
	_instances = deserialize_instances(data["_instances"])
	
	
func save_data() -> Dictionary:
	return {
		"_instances": serialize_data(_instances),
	}
	
	
func deserialize_instances(data:Array) -> Dictionary:
	var dict = {}
	for entity_data in data:
		var entity = PandoraEntityInstance.new("", "", [])
		entity.load_data(entity_data)
		dict[entity._id] = entity
	return dict


func serialize_data(data:Dictionary) -> Array[Dictionary]:
	var serialized_data:Array[Dictionary] = []
	for key in data:
		var entity = data[key] as PandoraEntityInstance
		serialized_data.append(entity.save_data())
	return serialized_data
	

# used for testing only
func _clear() -> void:
	_instances.clear()
	
	
func _create_properties(entity:PandoraEntity) -> Array[PandoraPropertyInstance]:
	var property_instances:Array[PandoraPropertyInstance] = []
	for property in entity.get_entity_properties():
		var id = id_generator.generate()
		var property_id = property.get_property_id()
		var default_value = property.get_default_value()
		property_instances.append(PandoraPropertyInstance.new(id, property, default_value))
	return property_instances
