@tool
extends PandoraPropertyControl


@onready var spin_box: SpinBox = $SpinBox


func _ready() -> void:
	spin_box.value = _property.get_default_value(_entity) as int
	spin_box.value_changed.connect(func(value:float): _property.set_default_value(_entity, int(value)))
