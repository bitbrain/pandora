@tool
class_name Dependency
extends PanelContainer

signal removed(dependency: Dictionary)

@onready var label: Label = $MarginContainer/HBoxContainer/Label

var dependency: Dictionary

func _ready() -> void:
	label.text = dependency["name"]

func _on_button_pressed() -> void:
	removed.emit(dependency)
	queue_free()
