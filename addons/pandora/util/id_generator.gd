class_name PandoraIDGenerator
extends RefCounted

var _nanoid := PandoraNanoIDGenerator.new(10)
var _sequential := PandoraSequentialIDGenerator.new()


func generate() -> String:
	var id_type := PandoraSettings.get_id_type()
	match id_type:
		PandoraSettings.IDType.SEQUENTIAL:
			return _sequential.generate()
		PandoraSettings.IDType.NANOID:
			return _nanoid.generate()
	push_error("unknown id type: %s" % id_type)
	return _sequential.generate()


func clear() -> void:
	_sequential.clear()


func save_data() -> Dictionary:
	return _sequential.save_data()


func load_data(data: Dictionary) -> void:
	_sequential.load_data(data)
