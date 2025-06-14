@tool
extends HSplitContainer

## called when the user intends to navigate to the
## original property of an inherited property.
signal inherited_property_selected(category_id: String, property_name: String)

const PropertyControlKvp = preload(
	"res://addons/pandora/ui/components/properties/property_control_kvp.tscn"
)
const PROPERTY_DEFAULT_NAME = "property"

@onready var property_bar: PandoraPropertyBar = %PropertyBar
@onready var property_list = %PropertyList
@onready var unselected_container = %UnselectedContainer
@onready var entity_attributes = %EntityAttributes
@onready var property_settings_container = %PropertySettingsContainer
@onready var scroll_container: ScrollContainer = %ScrollContainer

var current_entity: PandoraEntity


func _ready() -> void:
	property_bar.property_added.connect(_add_property.bind(true))
	set_entity(null)


## if possible, attempt to edit the given property key.
func edit_key(property_name: String) -> void:
	for property_control in property_list.get_children():
		var property = property_control._property
		if (
			property != null
			and property_name == property.get_property_name()
			and property.is_original()
		):
			property_control.edit_key()


func set_entity(entity: PandoraEntity) -> void:
	property_settings_container.visible = entity is PandoraCategory
	property_settings_container.set_property(null)
	for child in property_list.get_children():
		child.queue_free()
	self.current_entity = entity
	property_bar.visible = entity != null and entity is PandoraCategory
	property_list.visible = entity != null
	unselected_container.visible = entity == null
	entity_attributes.visible = entity != null

	if entity != null:
		entity_attributes.init(entity)
		var properties = entity.get_entity_properties()

		for property in properties:
			var scene = property_bar.get_scene_by_type(property.get_property_type().get_type_name())
			var control = scene.instantiate() as PandoraPropertyControl
			_add_property_control(control, property)


# The focus parameter is optional, and only used to ask the editor to also focus to the
# specified property
func _add_property(scene: PackedScene, focus: bool = false) -> void:
	if not current_entity is PandoraCategory:
		print("Cannot add custom properties to non-categories!")
		return
	var control = scene.instantiate() as PandoraPropertyControl
	var property = Pandora.create_property(
		current_entity as PandoraCategory,
		_generate_property_name(control.type, current_entity),
		control.type
	)
	if property != null:
		_add_property_control(control, property, focus)


func _add_property_control(control: PandoraPropertyControl, property: PandoraProperty, focus: bool = false) -> void:
	var control_kvp = PropertyControlKvp.instantiate()
	control.init(property)
	control_kvp.init(property, control, Pandora._entity_backend)
	control_kvp.inherited_property_selected.connect(
		func(category_id: String, property_name: String): inherited_property_selected.emit(
			category_id, property_name
		)
	)
	property_list.add_child(control_kvp)
	control_kvp.property_key_edit.grab_focus()
	control_kvp.original_property_selected.connect(property_settings_container.set_property)
	# First scroll to the control node and then apply an offset.
	# It's important to wait a frame before scrolling as for the documentation.
	if focus:
		await get_tree().process_frame
		scroll_container.ensure_control_visible(control_kvp)
		scroll_container.scroll_vertical = scroll_container.scroll_vertical + 100


func _generate_property_name(type: String, entity: PandoraEntity) -> String:
	var properties = entity.get_entity_properties()
	var property_name = type + " " + PROPERTY_DEFAULT_NAME
	if properties.is_empty() or not entity.has_entity_property(property_name):
		return property_name
	return property_name + str(properties.size())
