@tool
extends Control


@onready var tree:PandoraEntityTree = %EntityTree
@onready var save_button:Button = %SaveButton
@onready var create_entity_button:Button = %CreateEntityButton
@onready var create_category_button:Button = %CreateCategoryButton
@onready var property_editor = $Contents/DataContent/PropertyEditor
@onready var entity_search: LineEdit = %EntitySearch


var selected_entity:PandoraEntity


func _ready() -> void:
	save_button.pressed.connect(_save)
	tree.entity_selected.connect(_entity_selected)
	tree.selection_cleared.connect(func(): selected_entity = null)
	create_entity_button.pressed.connect(_create_entity)
	create_category_button.pressed.connect(_create_category)
	create_entity_button.disabled = true
	create_category_button.disabled = true
	tree.entity_selected.connect(property_editor.set_entity)
	tree.selection_cleared.connect(func(): property_editor.set_entity(null))
	entity_search.text_changed.connect(tree.search)
	
	# Add any newly created entity directly to the tree
	Pandora.entity_added.connect(tree.add_entity)


func _enter_tree() -> void:
	_populate_data.call_deferred()
	
	
func _entity_selected(entity:PandoraEntity) -> void:
	create_entity_button.disabled = not entity is PandoraCategory
	create_category_button.disabled = not entity is PandoraCategory
	selected_entity = entity
	
	
func _create_entity() -> void:
	if not selected_entity is PandoraCategory:
		return
	Pandora.create_entity("New Entity", selected_entity)
	
	
func _create_category() -> void:
	if not selected_entity is PandoraCategory:
		Pandora.create_category("New Category")
	else:
		Pandora.create_category("New Category", selected_entity)
	

func _populate_data() -> void:
	if not Pandora.is_loaded():
		print("Unable to load data - Pandora not initialised!")
		return
		
	var data = Pandora.get_all_categories()
	if data.is_empty():
		Pandora.create_category("Items")
	tree.set_data(data)
	
	if not Pandora.data_loaded.is_connected(_populate_data):
		Pandora.data_loaded.connect(_populate_data)
	
	
func _save() -> void:
	Pandora.save_data()
	print("Saved successfully.")
