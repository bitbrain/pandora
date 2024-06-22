@tool
extends Window

signal item_added(item: Variant)
signal item_removed(item: Variant)
signal item_updated(idx: int, new_item: Variant)

@onready var array_manager = $ArrayManager


func _ready():
	if owner.get_parent() is SubViewport:
		return
	array_manager.close_requested.connect(_on_close_requested)
	array_manager.item_added.connect(func(item: Variant): item_added.emit(item))
	array_manager.item_removed.connect(func(item: Variant): item_removed.emit(item))
	array_manager.item_updated.connect(func(idx: int, item: Variant): item_updated.emit(idx, item))


func open(property: PandoraProperty):
	popup_centered_clamped(Vector2i(800, 1000), 0.5)
	move_to_foreground()
	grab_focus()
	array_manager.open(property)


func _on_close_requested():
	hide()
	array_manager.close()
