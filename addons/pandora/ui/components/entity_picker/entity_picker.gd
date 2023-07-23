@tool
extends HBoxContainer


signal entity_selected(entity:PandoraEntity)


@onready var option_button = $OptionButton


var hint_string:String
var ids_to_entities = {}
var entity_ids_to_ids = {}


func _ready() -> void:
	option_button.get_popup().id_pressed.connect(_on_id_selected)
	set_data(Pandora.get_all_entities())
	

func set_data(entities:Array[PandoraEntity]) -> void:
	option_button.get_popup().clear()
	ids_to_entities.clear()
	entity_ids_to_ids.clear()
	var id_counter = 0
	for entity in entities:
		option_button.get_popup().add_icon_item(load(entity.get_icon_path()), entity.get_entity_name(), id_counter)
		ids_to_entities[id_counter] = entity
		entity_ids_to_ids[entity.get_entity_id()] = id_counter
		id_counter += 1
		

func select(entity:PandoraEntity) -> void:
	var id = entity_ids_to_ids[entity.get_entity_id()]
	option_button.select(id)


func _on_id_selected(id:int) -> void:
	entity_selected.emit(ids_to_entities[id])
