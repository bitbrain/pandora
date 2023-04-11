@tool
extends VBoxContainer


@onready var available_backends: OptionButton = %AvailableBackends


func _ready() -> void:
	var dynamic_backend = PandoraSettings.get_dynamic_backend()
	available_backends.add_icon_item(dynamic_backend.get_backend_icon(), dynamic_backend.get_backend_name())
	available_backends.select(0)
