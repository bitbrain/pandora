@tool
extends HBoxContainer

signal name_changed(new_name:String)

@onready var icon: TextureRect = $Icon
@onready var name_edit: LineEdit = %NameEdit
@onready var name_label: Label = %NameLabel

var current_name:String

func _ready() -> void:
	name_edit.text_submitted.connect(_name_changed)
	name_edit.focus_exited.connect(_read_mode)
	name_label.text = self.current_name
	name_edit.text = self.current_name


func set_name(name:String) -> void:
	self.current_name = name

func _edit_mode() -> void:
	if not name_edit.visible:
		name_label.visible = false
		name_edit.visible = true
		name_edit.grab_focus()
		
func _read_mode() -> void:
	if not name_label.visible:
		if name_edit.text != name_label.text:
			_name_changed(name_edit.text)
		name_label.visible = true
		name_edit.visible = false
		
func _name_changed(new_name:String) -> void:
	if new_name.length() > 2:
		self.current_name = new_name
		name_label.text = new_name
		name_edit.text = new_name
		_read_mode()
		name_changed.emit(new_name)
	else:
		name_edit.text = self.current_name
		

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.pressed && event.button_index == 1:
		_edit_mode()
