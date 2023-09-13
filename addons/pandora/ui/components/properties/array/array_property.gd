@tool
extends PandoraPropertyControl

@onready var array_editor = $ArrayEditor

func _ready() -> void:
	refresh()

func refresh() -> void:
	if _property != null:
		array_editor.set_property(_property)

