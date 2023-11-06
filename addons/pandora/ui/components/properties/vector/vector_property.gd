@tool
extends PandoraPropertyControl


enum VectorType { VECTOR_2, VECTOR_2I, VECTOR_3, VECTOR_3I }


const Vector2Type = preload("res://addons/pandora/model/types/vector2.gd")
const Vector2iType = preload("res://addons/pandora/model/types/vector2i.gd")
const Vector3Type = preload("res://addons/pandora/model/types/vector3.gd")
const Vector3iType = preload("res://addons/pandora/model/types/vector3i.gd")


@export var vector_type : VectorType


@onready var hbox : HBoxContainer = $HBoxContainer


var inputs : Array[SpinBox] = []


func _ready() -> void:
	var components : int
	match vector_type:
		VectorType.VECTOR_2, VectorType.VECTOR_2I:
			components = 2
		VectorType.VECTOR_3, VectorType.VECTOR_3I:
			components = 3
	for i in components:
		var input := _create_editor_spin_slider(i)
		inputs.append(input)
		hbox.add_child(input)
	if _property != null:
		_property.setting_changed.connect(_setting_changed)
		_property.setting_cleared.connect(_setting_changed)
	refresh()


func refresh() -> void:
	if _property != null:
		var min_value : int
		var max_value : int
		var step := 1.0
		var value = _property.get_default_value()
		match vector_type:
			VectorType.VECTOR_2:
				min_value = _property.get_setting(Vector2Type.SETTING_MIN_COMPONENT_VALUE) as int
				max_value = _property.get_setting(Vector2Type.SETTING_MAX_COMPONENT_VALUE) as int
				step = _property.get_setting(Vector2Type.SETTING_STEPS) as float
			VectorType.VECTOR_2I:
				min_value = _property.get_setting(Vector2iType.SETTING_MIN_COMPONENT_VALUE) as int
				max_value = _property.get_setting(Vector2iType.SETTING_MAX_COMPONENT_VALUE) as int
			VectorType.VECTOR_3:
				min_value = _property.get_setting(Vector3Type.SETTING_MIN_COMPONENT_VALUE) as int
				max_value = _property.get_setting(Vector3Type.SETTING_MAX_COMPONENT_VALUE) as int
				step = _property.get_setting(Vector3Type.SETTING_STEPS) as float
			VectorType.VECTOR_3I:
				min_value = _property.get_setting(Vector3iType.SETTING_MIN_COMPONENT_VALUE) as int
				max_value = _property.get_setting(Vector3iType.SETTING_MAX_COMPONENT_VALUE) as int
		for i in inputs.size():
			var input = inputs[i]
			input.min_value = min_value
			input.max_value = max_value
			input.step = step
			if value[i] != input.value:
				input.set_value_no_signal(value[i])



func _setting_changed(key:String) -> void:
	if (vector_type == VectorType.VECTOR_2 and
		(key == Vector2Type.SETTING_MIN_COMPONENT_VALUE or
		key == Vector2Type.SETTING_MAX_COMPONENT_VALUE or
		key == Vector2Type.SETTING_STEPS)) \
			or \
		(vector_type == VectorType.VECTOR_2I and
		(key == Vector2iType.SETTING_MIN_COMPONENT_VALUE or
		key == Vector2iType.SETTING_MAX_COMPONENT_VALUE)) \
			or \
		(vector_type == VectorType.VECTOR_3 and
		(key == Vector3Type.SETTING_MIN_COMPONENT_VALUE or
		key == Vector3Type.SETTING_MAX_COMPONENT_VALUE or
		key == Vector3Type.SETTING_STEPS)) \
			or \
		(vector_type == VectorType.VECTOR_3I and
		(key == Vector3iType.SETTING_MIN_COMPONENT_VALUE or
		key == Vector3iType.SETTING_MAX_COMPONENT_VALUE)):
			refresh()


func _create_editor_spin_slider(axis:int) -> SpinBox:
	var node := SpinBox.new()
	var label = ["x", "y", "z"][axis]
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.prefix = label
	if vector_type == VectorType.VECTOR_2 or vector_type == VectorType.VECTOR_3:
		node.step = 0.01
	node.focus_entered.connect(func(): focused.emit())
	node.focus_exited.connect(func(): unfocused.emit())
	node.value_changed.connect(
		func(v):
			var value = _property.get_default_value()
			value[axis] = v
			_property.set_default_value(value)
			property_value_changed.emit(value))
	return node
