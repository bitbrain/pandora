extends VBoxContainer

@onready var save_button = $HBoxContainer2/SaveButton

func _ready() -> void:
	save_button.pressed.connect(_save_all_data)
	
func _save_all_data() -> void:
	Pandora.get_item_server().flush()
