@tool
extends Button

const RELEASE_URL: String = "https://api.github.com/repos/bitbrain/pandora/releases"

@onready var http_request: HTTPRequest = %HTTPRequest
@onready var updater_window: AcceptDialog = $UpdaterWindow
@onready var updater: Control = $UpdaterWindow/UpdaterControl
@onready var post_update_window: ConfirmationDialog = $PostUpdateWindow


func _ready() -> void:
	self.hide()
	check_for_updates()


func get_version() -> String:
	var plugin_config: ConfigFile = ConfigFile.new()
	plugin_config.load("res://addons/pandora/plugin.cfg")
	return plugin_config.get_value("plugin", "version")


func check_for_updates() -> void:
	http_request.request(RELEASE_URL)


func version_to_number(ver: String) -> int:
	ver = ver.lstrip("v")
	ver = ver.split("+")[0]

	var parts = ver.split("-")
	var release_ver = parts[0]
	parts.remove_at(0)

	var phase = null
	if parts.size() > 0:
		phase = "-".join(parts)

	var nums = release_ver.split(".")
	var size = nums.size()
	var offset = 0 if phase == null else 1
	var value = 0

	for idx in range(size):
		var item = nums[idx]
		if item.is_valid_int():
			value += item.to_int() * (100 ** (size + offset - idx))

		# If the release is stable, add 75 to be greater than alpha, beta & rc
		if phase == null && idx == size - 1:
			value += 75

	# The lstrip is done seperately so it works even if the "." is not present
	if phase != null:
		if phase.begins_with("alpha"):
			value += phase.lstrip("alpha").lstrip(".").to_int()
		elif phase.begins_with("beta"):
			value += 25 + phase.lstrip("beta").lstrip(".").to_int()
		elif phase.begins_with("rc"):
			value += 50 + phase.lstrip("rc").lstrip(".").to_int()

	return value


func _on_http_request_completed(
	result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		return

	var res = JSON.parse_string(body.get_string_from_utf8())
	if typeof(res) != TYPE_ARRAY:
		return

	var curr_version_num = version_to_number(get_version())

	var new_versions: Array = (res as Array).filter(
		func(release): return version_to_number(release.tag_name) > curr_version_num
	)

	if new_versions.size() > 0:
		self.show()
		updater.releases = new_versions


func _on_update_button_pressed() -> void:
	updater_window.show()


func _on_updater_update_done(success: bool) -> void:
	if success:
		post_update_window.set_text("Updated Pandora successfully!\nRestart editor?")
	else:
		post_update_window.set_text("Could not update Pandora!\nRestart editor?")

	post_update_window.show()


func _on_post_update_window_confirmed() -> void:
	var plugin: EditorPlugin = Engine.get_meta("PandoraEditorPlugin")
	plugin.get_editor_interface().restart_editor(true)
