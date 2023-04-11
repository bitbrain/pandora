@tool
extends VBoxContainer

@onready var save_button = $HBoxContainer2/SaveButton
@onready var item_search_table: PandoraItemSearchTable = %ItemSearchTable

func _ready() -> void:
	save_button.pressed.connect(_save_all_data)
	_setup_resolver.call_deferred()
	item_search_table.on_selected.connect(_item_selected)

func _item_selected(id:String) -> void:
	print("Item selected:", id)
	
func _save_all_data() -> void:
	Pandora.flush(PandoraItem.get_data_type())

func _setup_resolver() -> void:
	item_search_table.set_create_with_name_resolver(Pandora.get_item_server().create_item)
