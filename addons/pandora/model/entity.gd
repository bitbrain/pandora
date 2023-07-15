class_name PandoraEntity extends Resource


class OverridingProperty extends PandoraProperty:
	
	
	var _property: PandoraProperty
	var _parent_entity: PandoraEntity


	func _init(parent_entity: PandoraEntity, property: PandoraProperty) -> void:
		self._property = property
		self._parent_entity = parent_entity
		self._property.name_changed.connect(_change_name)


	func set_default_value(value: Variant) -> void:
		_parent_entity._property_overrides[_property.get_property_name()] = value

	func get_default_value() -> Variant:
		if _parent_entity._property_overrides.has(_property.get_property_name()):
			return _parent_entity._property_overrides[_property.get_property_name()]
		return _property.get_default_value()


	func get_property_id() -> String:
		return _property.get_property_id()


	func get_property_name() -> String:
		return _property.get_property_name()


	func get_property_type() -> String:
		return _property.get_property_type()
		
	
	func is_original() -> bool:
		return _property._category_id == _parent_entity._id
		
		
	func is_overridden() -> bool:
		var override_exists = _parent_entity._property_overrides.has(_property.get_property_name())
		return override_exists and _parent_entity._property_overrides[get_property_name()] != _property.get_default_value()
		
		
	func reset_to_default() -> void:
		var had_override = _parent_entity._property_overrides.has(_property.get_property_name())
		if had_override:
			_parent_entity._property_overrides.erase(_property.get_property_name())
		
		
	
	func _change_name(old_name:String, new_name:String) -> void:
		if _parent_entity._property_overrides.has(old_name):
			var value = _parent_entity._property_overrides[old_name]
			_parent_entity._property_overrides.erase(old_name)
			_parent_entity._property_overrides[new_name] = value
		if _parent_entity._property_map.has(old_name):
			var old_property = _parent_entity._property_map[old_name]
			_parent_entity._property_map.erase(old_name)
			_parent_entity._property_map[new_name] = old_property
		var old_inherited_property = _parent_entity._inherited_properties[old_name]
		_parent_entity._inherited_properties.erase(old_name)
		_parent_entity._inherited_properties[new_name] = old_inherited_property
		


var _id:String
var _name:String
var _icon_path:String
var _category_id:String
# not persisted but computed at runtime
var _properties:Array[PandoraProperty] = []
# property name -> Property
var _property_map = {}
# property name -> InheritedProperty (cache)
var _inherited_properties = {}
var _property_overrides = {}


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
	if _property_map.has(name):
		var property = _property_map[name] as PandoraProperty
		if property._category_id != _id:
			if not _inherited_properties.has(name):
				_inherited_properties[name] = OverridingProperty.new(self, property)
			return _inherited_properties[name]
		return property
	else:
		for property in get_entity_properties():
			if property.get_property_name() == name:
				if not _property_map.has(name):
					_property_map[name] = property
				return property
	return null

	
func has_entity_property(name:String) -> bool:
	return get_entity_property(name) != null
	

func get_entity_properties() -> Array[PandoraProperty]:
	var properties:Array[PandoraProperty] = []
	for property in _properties:
		if property._category_id != _id:
			if not _inherited_properties.has(property.get_property_name()):
				_inherited_properties[property.get_property_name()] = OverridingProperty.new(self, property)
			properties.append(_inherited_properties[property.get_property_name()])
		else:
			properties.append(property)
	return properties
	
	
func get_category() -> PandoraCategory:
	if _category_id == null or _category_id == "":
		return null
	return Pandora.get_category(_category_id)


func load_data(data:Dictionary) -> void:
	_id = data["_id"]
	_name = data["_name"]
	_icon_path = data["_icon_path"]
	_category_id = data["_category_id"]
	_property_overrides = _load_overrides(data["_property_overrides"])
	
	
func save_data() -> Dictionary:
	return {
		"_id": _id,
		"_name": _name,
		"_icon_path": _icon_path,
		"_category_id": _category_id,
		"_property_overrides": _save_overrides()
	}


func _save_overrides() -> Dictionary:
	var output = {}
	for property_name in _property_overrides:
		var value = _property_overrides[property_name]
		output[property_name] = {
			"type": _find_property(property_name).get_property_type(),
			"value": PandoraProperty.write_value(value)
		}
	return output
	
	
func _load_overrides(data:Dictionary) -> Dictionary:
	var output = {}
	for property_name in data:
		var unparsed_data = data[property_name]
		output[property_name] = PandoraProperty.parse_value(unparsed_data["value"], unparsed_data["type"])
	return output
	
	
func _find_property(name:String) -> PandoraProperty:
	if _inherited_properties.has(name):
		return _inherited_properties[name]
	for property in _properties:
		if property.get_property_name() == name:
			return property
	return null
