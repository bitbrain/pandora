# displays a hierarchy of PandoraCategory in a Godot Control.
@tool
class_name PandoraEntityTree extends Tree


const CLEAR_ICON = preload("res://addons/pandora/icons/Clear.svg")


signal entity_selected(entity:PandoraEntity)
signal entity_deletion_issued(entity:PandoraEntity)
signal selection_cleared


@onready var loading_spinner = $LoadingSpinner


var entity_items: Dictionary


func _ready():
	entity_items = {}
	item_selected.connect(_clicked)
	item_edited.connect(_edited)
	
	if not entity_items.is_empty():
		loading_spinner.visible = false
		
	button_clicked.connect(_on_button_clicked)


## filters the existing list to the given search term
## if search term is empty the search gets cleared.
func search(text:String) -> void:
	for key in entity_items:
		var entity_item = entity_items[key] as TreeItem
		if text != "":
			var entity = entity_item.get_metadata(0) as PandoraEntity
			entity_item.set_collapsed_recursive(entity.get_entity_name().contains(text))
		else:
			entity_item.set_collapsed_recursive(false)
			

## selects the entity with the given ID	
func select(entity_id:String) -> void:
	var entity_item = entity_items[entity_id] as TreeItem
	entity_item.select(0)
	_clicked()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.double_click:
		if get_selected():
			get_selected().set_editable(0, true)
			edit_selected()
			accept_event()
	elif event is InputEventMouseButton and not event.double_click:
		if get_selected():
			get_selected().set_editable(0, false)
			# make sure to unselect when the child
			# did not handle this event!
			if event.is_pressed() and get_selected():
				deselect_all()
				selection_cleared.emit()
	

func set_data(category_tree:Array[PandoraEntity]) -> void:
	clear()
	_populate_tree(category_tree)
	if loading_spinner:
		loading_spinner.visible = false
	
	
func add_entity(entity: PandoraEntity) -> void:
	var parent_item = entity_items.get(entity._category_id)
	var entity_item = _create_item(parent_item, entity)
	# add the newly added entity to the entity_items dictionary
	entity_items[entity._id] = entity_item


func _clicked() -> void:
	var selected_item = get_selected()
	if not selected_item:
		return
	var entity = selected_item.get_metadata(0) as PandoraEntity
	entity_selected.emit(entity)
	
	
func _edited() -> void:
	var selected_item = get_selected()
	if not selected_item:
		return
	var entity = selected_item.get_metadata(0) as PandoraEntity
	if entity:
		entity._name = selected_item.get_text(0)


func _populate_tree(category_tree: Array[PandoraEntity], parent_item: TreeItem = null) -> void:
	var root_item = parent_item
	if not root_item:
		# make sure to create an empty parent
		# so we can hide it -> need to support
		# multiple root levels!
		root_item = create_item()
	for entity in category_tree:
		var new_item = _create_item(root_item, entity)
		# Add every entity to the dictionary, not just PandoraCategory entities
		entity_items[entity._id] = new_item
		if entity is PandoraCategory and entity._children and entity._children.size() > 0:
			_populate_tree(entity._children, new_item)


func _populate_tree_item(parent_item: TreeItem, parent_entity: PandoraEntity) -> void:
	for child in parent_entity._children:
		var child_item = _create_item(parent_item, child)
		if child is PandoraCategory:
			_populate_tree_item(child_item, child)


func _create_item(parent_item: TreeItem, entity:PandoraEntity) -> TreeItem:
	var item = create_item(parent_item)
	item.set_metadata(0, entity)
	item.set_text(0, entity.get_entity_name())
	item.set_selectable(0, true)
	item.set_editable(0, true)
	if entity.get_icon_path() != "":
		item.set_icon(0, load(entity.get_icon_path()))
	item.add_button(1, CLEAR_ICON, -1, false, "Delete entity")
	return item
	

func _on_button_clicked(item:TreeItem, column:int, id:int, mouse_button_index:int) -> void:
	var entity = item.get_metadata(0) as PandoraEntity
	entity_deletion_issued.emit(entity)
	item.get_parent().remove_child(item)
