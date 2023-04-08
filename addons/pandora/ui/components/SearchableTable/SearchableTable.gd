@tool
extends VBoxContainer

@onready var create_button = $CreateButton
@onready var search_edit = $SearchEdit
@onready var elements = $Elements

func _ready() -> void:
	pass
	
# How to ideally populate the table?
# We need to sync items in this list somehow
# Maybe hard refresh instead every time an entry
# has been modified?
