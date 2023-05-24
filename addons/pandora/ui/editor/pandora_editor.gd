@tool
extends Control


@export var editor_tab_bg := StyleBoxFlat.new()


@onready var tree = $EntityTree


var plugin_reference = null
var editors_manager : Control = null


func _enter_tree() -> void:
	Pandora.data_loaded.connect(_populate_data)

	
func _populate_data() -> void:
	var data = Pandora.get_item_backend().get_all()
	tree.set_data(data)
