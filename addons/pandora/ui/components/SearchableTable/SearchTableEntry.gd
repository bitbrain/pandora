@tool
class_name PandoraItemSearchEntry extends Panel

signal on_click


@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel


var current_name:String


func _ready() -> void:
	name_label.text = self.current_name


func set_name(name:String) -> void:
	self.current_name = name


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		on_click.emit()
