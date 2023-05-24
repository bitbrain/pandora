# displays a hierarchy of PandoraCategory in a Godot Control.
@tool
extends Tree


signal entity_selected(entity:PandoraEntity)


@onready var loading_spinner = $LoadingSpinner


var category_items: Dictionary


func _ready():
	item_selected.connect(_clicked)
	item_edited.connect(_edited)
	

func set_data(category_tree:Array[PandoraEntity]) -> void:
	_populate_tree(category_tree)
	loading_spinner.visible = false


func _clicked() -> void:
	var selected_item = get_selected()
	var entity = selected_item.get_metadata(0) as PandoraEntity
	entity_selected.emit(entity)
	
	
func _edited() -> void:
	var selected_item = get_selected()
	var entity = selected_item.get_metadata(0) as PandoraEntity
	if entity:
		entity._name = selected_item.get_text(0)


func _populate_tree(category_tree: Array[PandoraEntity], parent_item: TreeItem = null) -> void:
	# create an invisible root
	if not parent_item:
		create_item()
	var root_item = get_root()
	for entity in category_tree:
		if entity is PandoraCategory:
			var category_item = create_item(root_item) as TreeItem
			category_item.set_metadata(0, entity)
			category_item.set_text(0, entity.get_entity_name())
			if category_item != root_item:
				category_item.set_editable(0, true)
			if entity.get_icon_path() != "":
				category_item.set_icon(0, load(entity.get_icon_path()))
			category_items[entity._id] = category_item
			_populate_tree(entity._children, category_item)
		else:
			# Handle the case when the entity is not a category
			var child_item = create_item(root_item)
			child_item.set_metadata(0, entity)
			child_item.set_text(0, entity.get_entity_name())
			child_item.set_editable(0, true)

			if entity.get_icon_path() != "":
				child_item.set_icon(0, load(entity.get_icon_path()))


func _populate_tree_item(parent_item: TreeItem, parent_entity: PandoraEntity) -> void:
	for child in parent_entity._children:
		var child_item = create_item(parent_item)
		child_item.set_metadata(0, child)
		child_item.set_text(0, child.get_entity_name())
		child_item.set_editable(0, true)

		if child.get_icon_path() != "":
			child_item.set_icon(0, load(child.get_icon_path()))

		if child is PandoraCategory:
			_populate_tree_item(child_item, child)



func _on_entity_added(entity: PandoraEntity) -> void:
	var parent_item = category_items.get(entity._category_id)
	if parent_item:
		var entity_item = create_item(parent_item) as TreeItem
		entity_item.set_metadata(0, entity)
		entity_item.set_text(0, entity.get_entity_name())
		entity_item.set_editable(0, true)
		if entity.get_icon_path() != "":
			entity_item.set_icon(0, load(entity.get_icon_path()))
