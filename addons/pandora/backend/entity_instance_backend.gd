## Manages entity instances which are usually not shipped with the
## game but rather are created at game runtime.
class_name PandoraEntityInstanceBackend extends RefCounted


const id_generator = preload("res://addons/pandora/utils/id_generator.gd")


var _instances:Dictionary = {}


## Creates a new entity instance of an existing entity
func create_entity_instance(of_entity:PandoraEntity) -> PandoraEntityInstance:
	var entity_instance = PandoraEntityInstance.new(id_generator.generate(), of_entity.get_entity_id(), _create_properties(of_entity))
	_instances[entity_instance._id] = entity_instance
	return entity_instance


## Returns an existing entity instance
func get_entity_instance(instance_id:String) -> PandoraEntityInstance:
	if not _instances.has(instance_id):
		return null
	return _instances[instance_id]


## Deletes an existing entity instance
func delete_entity_instance(instance_id:String) -> bool:
	if not _instances.has(instance_id):
		return false
	_instances.erase(instance_id)
	return true


## Initialize this backend with the given data dictionary.
## The data needs to come from a source that was produced via
## the save_data() method.
## Also requires a PandoraEntityBackend to wire the instances to
## their respective entities. Therefore, the passed backend needs to be
## initialized first.
func load_data(data:Dictionary, backend:PandoraEntityBackend) -> void:
	_instances = _deserialize_instances(data["_instances"], backend)


## Returns a dictionary that can be used for further storage.
## Call the load_data(data) method to re-initialize a backend.
func save_data() -> Dictionary:
	return {
		"_instances": _serialize_data(_instances),
	}


func _deserialize_instances(data:Array, backend:PandoraEntityBackend) -> Dictionary:
	var dict = {}
	for entity_data in data:
		var entity = PandoraEntityInstance.new("", "", [])
		entity.load_data(entity_data, backend)
		dict[entity._id] = entity
	return dict


func _serialize_data(data:Dictionary) -> Array[Dictionary]:
	var serialized_data:Array[Dictionary] = []
	for key in data:
		var entity = data[key] as PandoraEntityInstance
		serialized_data.append(entity.save_data())
	return serialized_data
	

# used for testing only
func _clear() -> void:
	_instances.clear()


## Generates instanced properties from an existing entity.
## A property that is instanced can be change its value independently
## of the original property.
func _create_properties(entity:PandoraEntity) -> Array[PandoraPropertyInstance]:
	var property_instances:Array[PandoraPropertyInstance] = []
	for property in entity.get_entity_properties():
		var id = id_generator.generate()
		var property_id = property.get_property_id()
		var default_value = property.get_default_value()
		property_instances.append(PandoraPropertyInstance.new(id, property, default_value))
	return property_instances
