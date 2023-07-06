@tool
extends VBoxContainer


@onready var property_bar = %PropertyBar
@onready var property_list = %PropertyList
@onready var unselected_container = %UnselectedContainer


var current_entity:PandoraEntity


func _ready() -> void:
	set_entity(null)


func set_entity(entity:PandoraEntity) -> void:
	self.current_entity = entity
	property_bar.visible = entity != null and entity is PandoraCategory
	property_list.visible = entity != null
	unselected_container.visible = entity == null
	
	
func _add_property() -> void:
	if not current_entity is PandoraCategory:
		print("Cannot add custom properties to non-categories!")
		return
	var property = Pandora.create_property(current_entity as PandoraCategory, "max_stack_size", 123)
	_add_property_control(property)


func _add_property_control(property:PandoraProperty) -> void:
	# TODO implement me!
	pass
	
