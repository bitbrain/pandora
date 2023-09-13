@tool
extends HBoxContainer

signal property_type_selected(property_type: PandoraPropertyType)

@onready var option_button = $OptionButton

var hint_string:String
var _ids_to_types = {}
var _type_ids_to_ids = {}
var _types: Array[PandoraPropertyType]

func _ready():
	option_button.get_popup().id_pressed.connect(_on_id_selected)
	
func set_data()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_id_selected():
	pass