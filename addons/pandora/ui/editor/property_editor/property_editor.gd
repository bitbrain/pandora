@tool
extends VBoxContainer


@onready var property_bar:PandoraPropertyBar = %PropertyBar
@onready var property_list = %PropertyList
@onready var unselected_container = %UnselectedContainer


var current_entity:PandoraEntity


func _ready() -> void:
	property_bar.property_added.connect(_add_property)
	set_entity(null)


func set_entity(entity:PandoraEntity) -> void:
	self.current_entity = entity
	property_bar.visible = entity != null and entity is PandoraCategory
	property_list.visible = entity != null
	unselected_container.visible = entity == null
	
	
func _add_property(scene:PackedScene) -> void:
	if not current_entity is PandoraCategory:
		print("Cannot add custom properties to non-categories!")
		return
	var control = scene.instantiate() as PandoraPropertyControl
	var property = Pandora.create_property(current_entity as PandoraCategory, "property", control.type)
	property_list.add_child(control)
	control.set_property(property)
