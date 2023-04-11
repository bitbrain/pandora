@tool
class_name PandoraItemSearchTable extends VBoxContainer

signal on_selected(id:String)

const SearchEntry = preload("res://addons/pandora/ui/components/SearchableTable/SearchTableEntry.tscn")


@onready var add_new_item_node = %AddNewItem
@onready var search_edit = $SearchEdit
@onready var elements = %Elements


var _create_with_name_resolver:Callable

func _ready() -> void:
	add_new_item_node.text_submitted.connect(_create_new_item)
	
func set_create_text(text:String) -> void:
	add_new_item_node.text = text
	
func set_create_with_name_resolver(resolver:Callable) -> void:
	_create_with_name_resolver = resolver

func add_item(identifiable:PandoraIdentifiableWithDetails) -> void:
	var entry = SearchEntry.instantiate()
	entry.set_name(identifiable.name)
	elements.add_child(entry)
	entry.on_click.connect(func(): on_selected.emit(identifiable.get_id()))


func _create_new_item(name:String) -> void:
	add_new_item_node.clear()
	var identifiable = _create_with_name_resolver.call(name) as PandoraIdentifiable
	var entry = SearchEntry.instantiate()
	entry.set_name(name)
	elements.add_child(entry)
	entry.on_click.connect(func(): on_selected.emit(identifiable.get_id()))
