## This class allows us to make it easier 
## to specify new types, e.g. by adding a new file 
## which then internally specifies everything Pandora needs to know,
## including serialization, property settings and validation.
class_name PandoraPropertyType extends RefCounted


class UndefinedType extends PandoraPropertyType:
	
	func _init():
		super("undefined", {}, null, "")


var _type_name:String
var _settings:Dictionary
var _default_value:Variant
var _type_icon_path:String


func _init(type_name:String, settings:Dictionary, default_value:Variant, type_icon_path:String) -> void:
	self._type_name = type_name
	self._settings = settings
	self._default_value = default_value
	self._type_icon_path = type_icon_path
	
	
func parse_value(variant:Variant, settings:Dictionary = {}) -> Variant:
	return variant
	
	
func write_value(variant:Variant) -> Variant:
	return variant


func get_type_name() -> String:
	return _type_name


func get_settings() -> Dictionary:
	return _settings

func has_settings() -> bool:
	return _settings.is_empty() == false


func get_default_value() -> Variant:
	return _default_value

func get_type_icon_path() -> String:
	return _type_icon_path
	
	
func is_valid(variant:Variant) -> bool:
	return false


static func lookup(name:String) -> PandoraPropertyType:
	if name == "":
		return UndefinedType.new()
	var ScriptType = load("res://addons/pandora/model/types/" + name + ".gd")
	if ScriptType != null and ScriptType.has_source_code():
		return ScriptType.new()
	else:
		return UndefinedType.new()
