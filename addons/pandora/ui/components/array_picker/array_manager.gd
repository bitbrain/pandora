@tool
extends PanelContainer

func _ready():
	if owner.get_parent() is SubViewport:
		return

func _process(delta):
	pass

func open():
	pass

func close():
	pass
