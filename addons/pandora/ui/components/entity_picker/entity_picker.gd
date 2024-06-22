@tool
extends HBoxContainer

signal entity_selected(entity: PandoraEntity)

@onready var option_button = $OptionButton

var hint_string: String
var categories_only: bool:
	set(v):
		var old_value = categories_only
		categories_only = v
		if old_value != categories_only:
			_invalidate.call_deferred()

var _ids_to_entities = {}
var _entity_ids_to_ids = {}
var _entities: Array[PandoraEntity]
var _category_id_filter: String:
	set(v):
		var old_value = _category_id_filter
		_category_id_filter = v
		if old_value != _category_id_filter:
			_invalidate.call_deferred()
var _sort: Callable = func(a, b): return false


func _ready() -> void:
	option_button.get_popup().id_pressed.connect(_on_id_selected)
	_invalidate()


func set_sort(sort: Callable) -> void:
	self._sort = sort
	_invalidate()


func set_filter(category_id: String) -> void:
	self._category_id_filter = category_id
	_invalidate()


func set_data(entities: Array[PandoraEntity]) -> void:
	self._entities = entities
	_ids_to_entities.clear()
	_entity_ids_to_ids.clear()
	var id_counter = 0
	option_button.get_popup().clear()
	for entity in _entities:
		option_button.get_popup().add_icon_item(
			load(entity.get_icon_path()), entity.get_entity_name(), id_counter
		)

		var editor_plugin: EditorPlugin = (
			Engine.get_meta("PandoraEditorPlugin")
			if Engine.has_meta("PandoraEditorPlugin")
			else null
		)
		if editor_plugin:
			option_button.get_popup().set_item_icon_max_width(
				id_counter, editor_plugin.get_editor_interface().get_editor_scale() * 16
			)
		# Godot 4.1+
		if option_button.get_popup().has_method("set_item_icon_modulate"):
			option_button.get_popup().set_item_icon_modulate(id_counter, entity.get_icon_color())
		_ids_to_entities[id_counter] = entity
		_entity_ids_to_ids[entity.get_entity_id()] = id_counter
		id_counter += 1


func select(entity: PandoraEntity) -> void:
	var id = _entity_ids_to_ids[entity.get_entity_id()]
	option_button.select(id)
	option_button.modulate = entity.get_icon_color()


func _on_id_selected(id: int) -> void:
	entity_selected.emit(_ids_to_entities[id])


func _invalidate() -> void:
	var filter = Pandora.get_category(_category_id_filter) if _category_id_filter else null
	if categories_only:
		set_data(Pandora.get_all_categories(filter, _sort))
	else:
		set_data(Pandora.get_all_entities(filter, _sort))
