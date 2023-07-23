## Manages entity instances which are usually not shipped with the
## game but rather are created at game runtime.
class_name PandoraEntityInstanceBackend extends RefCounted

const ENTITY_INSTANCE_ID_CONTEXT = "entity_instance"

# generates ids for new entities
var _id_generator:PandoraIdGenerator


func _init(id_generator:PandoraIdGenerator) -> void:
	self._id_generator = id_generator

## Creates a new entity instance of an existing entity
func create_entity_instance(of_entity:PandoraEntity) -> PandoraEntityInstance:
	return PandoraEntityInstance.new(_id_generator.generate(ENTITY_INSTANCE_ID_CONTEXT), of_entity.get_entity_id(), _create_properties(of_entity))


## Generates instanced properties from an existing entity.
## A property that is instanced can be change its value independently
## of the original property.
func _create_properties(entity:PandoraEntity) -> Array[PandoraPropertyInstance]:
	var property_instances:Array[PandoraPropertyInstance] = []
	for property in entity.get_entity_properties():
		var id = _id_generator.generate(ENTITY_INSTANCE_ID_CONTEXT)
		var property_id = property.get_property_id()
		var default_value = property.get_default_value()
		property_instances.append(PandoraPropertyInstance.new(id, property, default_value))
	return property_instances
