class_name PandoraEntity extends Resource


var _id:String
var _name:String
var _icon_path:String
var _category_id:String
# not persisted but computed at runtime
var _properties:Array[PandoraProperty] = []


func _init(id:String, name:String, icon_path:String, category_id:String) -> void:
	self._id = id
	self._name = name
	self._icon_path = icon_path
	self._category_id = category_id

	
func get_entity_id() -> String:
	return _id
	
	
func get_entity_name() -> String:
	return tr(_name)
	
	
func get_icon_path() -> String:
	if _icon_path == "":
		return "res://addons/pandora/icons/KeyValue.svg"
	return _icon_path
	
	
func get_category_id() -> String:
	return _category_id
	
	
func get_entity_property(name:String) -> PandoraProperty:
	for property in _properties:
		if property.get_property_name() == name:
			return property
	return null
	
	
func has_entity_property(name:String) -> bool:
	return get_entity_property(name) != null
	
	
func get_entity_properties() -> Array[PandoraProperty]:
	return _properties
	
	
func get_category() -> PandoraCategory:
	if _category_id == null or _category_id == "":
		return null
	return Pandora.get_category(_category_id)


func load_data(data:Dictionary) -> void:
	_id = data["_id"]
	_name = data["_name"]
	_icon_path = data["_icon_path"]
	_category_id = data["_category_id"]
	
	
func save_data() -> Dictionary:
	return {
		"_id": _id,
		"_name": _name,
		"_icon_path": _icon_path,
		"_category_id": _category_id
	}
