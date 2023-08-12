@tool
extends Label


var tween:Tween

func _ready() -> void:
	self_modulate.a = 0.0


func popup() -> void:
	if tween and tween.is_running():
		tween.stop()
	self_modulate.a = 1.0
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "self_modulate:a", 0.0, 1.5)\
	.set_delay(2.0);
