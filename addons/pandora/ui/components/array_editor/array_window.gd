@tool
extends Window

@onready var array_manager = $ArrayManager

func _ready():
	if owner.get_parent() is SubViewport:
		return
	array_manager.close_requested.connect(_on_close_requested)

func open(property: PandoraProperty):
	popup_centered_clamped(Vector2i(800, 1000), 0.5)
	move_to_foreground()
	grab_focus()
	array_manager.open(property)

func _on_close_requested():
	hide()
	array_manager.close()
