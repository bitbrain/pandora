@tool
extends EditorPlugin

const PandoraEditor := preload("res://addons/pandora/ui/editor/pandora_editor.tscn")
const PandoraIcon := preload("res://addons/pandora/icons/pandora-icon.svg")


var editor_view


func _init() -> void:
	self.name = 'PandoraPlugin'


func _enter_tree() -> void:
	add_autoload_singleton("PandoraSettings", "res://addons/pandora/settings/pandora_settings.gd")
	add_autoload_singleton("Pandora", "res://addons/pandora/api.tscn")
	editor_view = PandoraEditor.instantiate()
	editor_view.plugin_reference = self
	editor_view.hide()
	get_editor_interface().get_editor_main_screen().add_child(editor_view)
	_make_visible(false)
	# initialise data the next frame so nodes get the chance
	# to connect to required signals!
	Pandora.call_deferred("load_data_async")


func _exit_tree() -> void:
	Pandora.save_data()
	if editor_view:
		remove_control_from_bottom_panel(editor_view)
		editor_view.queue_free()


func _make_visible(visible:bool) -> void:
	if editor_view:
		editor_view.visible = visible


func _has_main_screen() -> bool:
	return true


func _get_plugin_name() -> String:
	return "Pandora"
	

func _get_plugin_icon() -> Texture2D:
	return PandoraIcon
