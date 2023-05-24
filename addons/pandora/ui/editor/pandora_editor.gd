@tool
extends Control

@onready var tree:PandoraEntityTree = $EntityTree
@onready var save_button:Button = $SaveButton
@onready var create_entity_button:Button = $HBoxContainer/CreateEntityButton
@onready var create_category_button:Button = $HBoxContainer/CreateCategoryButton

var selected_entity:PandoraEntity

func _ready() -> void:
	save_button.pressed.connect(_save)
	tree.entity_selected.connect(_entity_selected)
	create_entity_button.pressed.connect(_create_entity)
	create_category_button.pressed.connect(_create_category)
	create_entity_button.disabled = true
	create_category_button.disabled = true
	
	# Add any newly created entity directly to the tree
	Pandora.get_item_backend().entity_added.connect(tree.add_entity)
	
	# initialise data the next frame so nodes get the chance
	# to connect to required signals!
	Pandora.call_deferred("load_data_async")


func _enter_tree() -> void:
	Pandora.data_loaded.connect(_populate_data)
	
	
func _entity_selected(entity:PandoraEntity) -> void:
	create_entity_button.disabled = not entity is PandoraCategory
	create_category_button.disabled = not entity is PandoraCategory
	selected_entity = entity
	
	
func _create_entity() -> void:
	if not selected_entity is PandoraCategory:
		return
	var backend = Pandora.get_item_backend() as PandoraEntityBackend
	backend.create_entity("New Entity", selected_entity)
	
	
func _create_category() -> void:
	if not selected_entity is PandoraCategory:
		return
	var backend = Pandora.get_item_backend() as PandoraEntityBackend
	backend.create_category("New Category", selected_entity)
	

func _populate_data() -> void:
	var data = Pandora.get_item_backend().get_all()
	if data.is_empty():
		# Pandora not initialised yet! Create initial categories
		var item_backend = Pandora.get_item_backend() as PandoraEntityBackend
		item_backend.create_category("Items")
	tree.set_data(data)
	
	
func _save() -> void:
	Pandora.save_data()
	print("Saved successfully.")
