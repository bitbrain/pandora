extends CenterContainer


@export var item:Item
@export var entity:PandoraEntity


@onready var label = $Label


func _ready() -> void:
	label.text += item.get_entity_id() + " - "+ item.get_entity_name() + '\n'
	var copper_ore = Pandora.get_entity(Ores.COPPER_ORE) as Item
	label.text += copper_ore.get_entity_name() + '\n'

	var copper_instance = copper_ore.instantiate()

	label.text += copper_instance.get_string("Description") + '\n'

	label.text += str(copper_ore.get_rarity().get_rarity_color()) + '\n'
