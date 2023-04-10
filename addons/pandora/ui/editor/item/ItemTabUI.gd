@tool
extends VBoxContainer

@onready var save_button = $HBoxContainer2/SaveButton
@onready var item_search_table: PandoraItemSearchTable = %ItemSearchTable

func _ready() -> void:
	save_button.pressed.connect(_save_all_data)
	item_search_table.call_deferred("set_create_with_name_resolver", Pandora.get_item_server().create_item)
	item_search_table.on_selected.connect(_item_selected)

func _item_selected(id:String) -> void:
	print("Item selected:", id)
	
func _save_all_data() -> void:
	Pandora.get_item_server().flush()
