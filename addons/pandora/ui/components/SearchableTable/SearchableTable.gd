@tool
extends VBoxContainer

const SearchEntry = preload("res://addons/pandora/ui/components/SearchableTable/SearchTableEntry.tscn")

@onready var add_new_item = %AddNewItem
@onready var search_edit = $SearchEdit
@onready var elements = %Elements

func _ready() -> void:
	add_new_item.text_submitted.connect(_add_new_item)
	
func _add_new_item(name:String) -> void:
	add_new_item.clear()
	var item = Pandora.get_item_server().create_item(name)
	var entry = SearchEntry.instantiate()
	entry.set_name(name)
	elements.add_child(entry)
