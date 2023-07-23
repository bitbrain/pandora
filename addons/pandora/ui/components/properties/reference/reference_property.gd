@tool
extends PandoraPropertyControl


func _ready() -> void:
	refresh()
	#line_edit.text_changed.connect(
	#	func(text:String):
	#		_property.set_default_value(text)
	#		property_value_changed.emit())


func refresh() -> void:
	if _property != null:
		pass
