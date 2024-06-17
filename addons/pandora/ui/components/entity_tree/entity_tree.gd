# displays a hierarchy of PandoraCategory in a Godot Control.
@tool
class_name PandoraEntityTree extends Tree


const CLEAR_ICON = preload("res://addons/pandora/icons/Clear.svg")


signal entity_selected(entity:PandoraEntity)
signal entity_deletion_issued(entity:PandoraEntity)
signal selection_cleared
signal entity_moved(source: PandoraEntity, target: PandoraEntity, drop_section: int)

@onready var loading_spinner = $LoadingSpinner
@onready var confirmation_dialog = $ConfirmationDialog


var entity_items: Dictionary
var drag_preview_label : Label


func _ready():
	entity_items = {}
	item_selected.connect(_clicked)
	item_edited.connect(_edited)

	if not entity_items.is_empty():
		loading_spinner.visible = false


## filters the existing list to the given search term
## if search term is empty the search gets cleared.
func search(text:String) -> void:
	var root = get_root()
	for top_item in root.get_children():
		_search_item_recursive(top_item, text)


func _search_item_recursive(item: TreeItem, text: String) -> bool:
	var entity = item.get_metadata(0) as PandoraEntity
	# always succeed on empty search!
	var matches_search = (text == "") or entity.get_entity_name().to_lower().contains(text.to_lower())
	
	for sub in item.get_children():
		var submatch = _search_item_recursive(sub, text)
		matches_search = matches_search or submatch
	
	item.visible = matches_search
	return matches_search


func queue_delete(entity_id:String) -> void:
	var item = entity_items[entity_id]
	var entity = item.get_metadata(0) as PandoraEntity
	confirm("Confirmation Needed", "Are you sure you want to delete '%s'?" % entity.get_entity_name(), func():
		entity_deletion_issued.emit(entity)
		if item.get_parent() != null:
			item.get_parent().remove_child(item)
		deselect_all()
		selection_cleared.emit()
	)



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
	elif event is InputEventMouseButton and not event.double_click and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if get_selected():
			get_selected().set_editable(0, false)
			# make sure to unselect when the child
			# did not handle this event!
			if event.is_pressed() and get_selected():
				deselect_all()
				selection_cleared.emit()


func set_data(category_tree:Array[PandoraEntity]) -> void:
	clear()
	entity_items.clear()
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
		entity.set_entity_name(selected_item.get_text(0))


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

	_sort_tree(root_item)


func _populate_tree_item(parent_item: TreeItem, parent_entity: PandoraEntity) -> void:
	for child in parent_entity._children:
		var child_item = _create_item(parent_item, child)
		if child is PandoraCategory:
			_populate_tree_item(child_item, child)

func _sort_tree(item: TreeItem):
	var children: Array = []
	var child = item.get_first_child()
	while child:
		children.append(child)
		child = child.get_next()
	children.sort_custom(func(a: TreeItem, b: TreeItem) -> bool:
		var a_index = int(a.get_metadata(0).get_index())
		var b_index = int(b.get_metadata(0).get_index())
		if a_index < b_index:
			return true
		elif a_index > b_index:
			return false
		else:
			return false
	)
	
	for i in range(len(children) - 1):
		children[i].move_before(children[i + 1])
		
	for c in children:
		_sort_tree(c)

func _create_item(parent_item: TreeItem, entity:PandoraEntity) -> TreeItem:
	var item = create_item(parent_item) as TreeItem
	item.set_metadata(0, entity)
	item.set_text(0, entity.get_entity_name())
	item.set_selectable(0, true)
	item.set_editable(0, true)
	item.set_tooltip_text(0, "Entity ID: " + entity.get_entity_id())
	if entity.get_icon_path() != "":
		item.set_icon(0, load(entity.get_icon_path()))
		var editor_plugin: EditorPlugin = Engine.get_meta("PandoraEditorPlugin") if Engine.has_meta("PandoraEditorPlugin") else null
		if editor_plugin:
			item.set_icon_max_width(0, editor_plugin.get_editor_interface().get_editor_scale() * 16)
	item.set_icon_modulate(0, entity.get_icon_color())
	entity.icon_changed.connect(func(new_path): _on_icon_changed(entity.get_entity_id(), new_path))
	entity.icon_color_changed.connect(func(new_color): _on_icon_color_changed(entity.get_entity_id(), new_color))
	return item


func _on_icon_changed(entity_id:String, new_path:String) -> void:
	var item = entity_items[entity_id] as TreeItem
	item.set_icon(0, load(new_path))
	# propagate the change to all children if any
	for child in item.get_children():
		_on_icon_changed(child.get_metadata(0).get_entity_id(), child.get_metadata(0).get_icon_path())

func _on_icon_color_changed(entity_id:String, new_color:Color) -> void:
	var item = entity_items[entity_id] as TreeItem
	item.set_icon_modulate(0, new_color)
	# propagate the change to all children if any
	for child in item.get_children():
		_on_icon_color_changed(child.get_metadata(0).get_entity_id(), child.get_metadata(0).get_icon_color())
	
func _get_drag_data(_at_position):
	if get_selected():
		set_drop_mode_flags(DROP_MODE_INBETWEEN | DROP_MODE_ON_ITEM)

		if drag_preview_label == null or drag_preview_label.is_queued_for_deletion():
			drag_preview_label = Label.new()

		drag_preview_label.text = get_selected().get_text(0)
		set_drag_preview(drag_preview_label)
		
		return get_selected()

func _can_drop_data(at_position, source):
	if not source is TreeItem:
		return false

	var target = get_item_at_position(at_position)
	
	# Return false if the target is the source
	if target == source:
		return false

	# Return false if the source already is a parent of the target
	if source.get_parent() == target:
		return false
	
	# Return false if the target is a child of the source
	if not target or target.get_parent() == source:
		return false
	
	var source_entity: PandoraEntity = source.get_metadata(0)
	var target_entity: PandoraEntity = target.get_metadata(0)

	# If source is an Entity
	if source_entity is PandoraEntity and not source_entity is PandoraCategory:
		# Entity can't be left outside of a Category
		if target_entity._category_id.is_empty() and get_drop_section_at_position(at_position) != PandoraEntityBackend.DropSection.INSIDE:
			return false
		if target_entity is PandoraCategory or get_drop_section_at_position(at_position) != PandoraEntityBackend.DropSection.INSIDE:
			return true
	# If source is a Category
	elif source_entity is PandoraCategory:
		if target_entity is PandoraCategory:
			return true
	return false

func _drop_data(at_position, source):
	var target = get_item_at_position(at_position)
	if not target:
		return false

	var source_entity: PandoraEntity = source.get_metadata(0)
	var target_entity: PandoraEntity = target.get_metadata(0)

	var drop_section: PandoraEntityBackend.DropSection = get_drop_section_at_position(at_position)

	var will_properties_change: bool = Pandora.check_if_properties_will_change_on_move(source_entity, target_entity, drop_section)

	if will_properties_change:
		confirm("Confirmation Needed", "Moving will alter the properties. Do you wish to proceed?", func():
			move_item(source, target, drop_section)
		)
	else:
		move_item(source, target, drop_section)

	
func move_item(source: TreeItem, target: TreeItem, drop_section: PandoraEntityBackend.DropSection):
	var source_entity: PandoraEntity = source.get_metadata(0)
	var target_entity: PandoraEntity = target.get_metadata(0)

	if drop_section == PandoraEntityBackend.DropSection.INSIDE:
		source.get_parent().remove_child(source)
		target.add_child(source)
	elif drop_section == PandoraEntityBackend.DropSection.ABOVE:
		source.move_before(target)
	elif drop_section == PandoraEntityBackend.DropSection.BELOW:
		source.move_after(target)

	deselect_all()
	selection_cleared.emit()

	entity_moved.emit(source_entity, target_entity, drop_section)

func confirm(title: String, body: String, callback: Callable):
	confirmation_dialog.dialog_text = body
	confirmation_dialog.title = title
	confirmation_dialog.confirmed.connect(callback)
	confirmation_dialog.popup()
