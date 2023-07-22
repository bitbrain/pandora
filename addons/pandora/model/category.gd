class_name PandoraCategory extends PandoraEntity

# not persisted but computed at runtime
var _children:Array[PandoraEntity] = []


func get_child(entity_id:String) -> PandoraEntity:
	for child in _children:
		if child.get_entity_id() == entity_id:
			return child
	return null


func get_icon_path() -> String:
	if _icon_path == "":
		return "res://addons/pandora/icons/Folder.svg"
	return _icon_path


func _delete_property(name:String) -> void:
	super._delete_property(name)
	for child in _children:
		child._delete_property(name)
