class_name PandoraCategory extends PandoraEntity

# not persisted but computed at runtime
var _children:Array[PandoraEntity] = []


func get_icon_path() -> String:
	if _icon_path == "":
		return "res://addons/pandora/icons/Folder.svg"
	return _icon_path
