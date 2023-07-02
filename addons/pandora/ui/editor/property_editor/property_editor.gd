@tool
extends VBoxContainer


@onready var property_bar = $PropertyBar
@onready var property_list = $PropertyList
@onready var unselected_container = $UnselectedContainer


func _ready() -> void:
	set_entity(null)


func set_entity(entity:PandoraEntity) -> void:
	property_bar.visible = entity != null
	property_list.visible = entity != null
	unselected_container.visible = entity == null
