@tool
extends CenterContainer

@onready var rotation_sprite = $Control/RotationSprite


func _ready() -> void:
	_tween()


func _tween() -> void:
	var tween = create_tween()
	rotation_sprite.rotation_degrees = -360
	(
		tween
		. tween_property(rotation_sprite, "rotation_degrees", 360, 1.5)
		. set_ease(Tween.EASE_IN_OUT)
		. set_trans(Tween.TRANS_CUBIC)
		. finished
		. connect(_tween)
	)
