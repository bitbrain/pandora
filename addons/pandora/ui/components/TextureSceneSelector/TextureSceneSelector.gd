extends HBoxContainer

signal file_selected(path:String)

@onready var select_button := $SelectIconButton
@onready var dialog = $FileDialog

func _ready() -> void:
	select_button.pressed.connect(dialog.show)
	dialog.file_selected.connect(func(path): file_selected.emit(path))
