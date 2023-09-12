@tool
extends Window

@onready var edit_array_btn: Button = get_node("../EditArrayButton")

func _ready():
	if owner.get_parent() is SubViewport:
		return
	edit_array_btn.pressed.connect(open)


func open():
	popup_centered_clamped(Vector2i(400, 500), 0.5)
	move_to_foreground()
	grab_focus()
	$ArrayManager.open()

func _on_close_requested():
	hide()
	$ArrayManager.close()
