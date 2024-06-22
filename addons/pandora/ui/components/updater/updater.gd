@tool
extends Control

signal update_done(success: bool)

const TEMP_FILE_NAME: String = "user://temp.zip"

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var release_text: TextEdit = $VBoxContainer/ReleaseText
@onready var release_link: LinkButton = $VBoxContainer/CenterContainer2/LinkButton
@onready var download_btn: Button = $VBoxContainer/CenterContainer/DownloadButton
@onready var version_text: Label = $VBoxContainer/VersionText

var releases: Array = []:
	set(value):
		releases = value
		_update_ui()
	get:
		return releases


func _update_ui() -> void:
	if releases.is_empty():
		return

	var release_notes_text = ""
	for release in releases:
		release_notes_text += "Release " + release.tag_name + "\n" + release.body + "\n\n"
	release_notes_text = release_notes_text.rstrip("\n")
	release_text.set_text(release_notes_text)

	version_text.set_text("Latest version: " + releases[0].tag_name)
	release_link.set_uri(releases[0].html_url)


func _on_download_button_pressed() -> void:
	if releases.is_empty():
		self.update_done.emit(false)
		self.hide()
		return

	if FileAccess.file_exists("res://examples/inventory/inventory_example.gd"):
		prints("You can't update the addon from within itself.")
		return

	http_request.request(releases[0].zipball_url)
	download_btn.disabled = true
	download_btn.set_text("Downloading")


func _on_http_request_request_completed(
	result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		self.update_done.emit(false)
		self.hide()
		return

	var zip_file: FileAccess = FileAccess.open(TEMP_FILE_NAME, FileAccess.WRITE)
	zip_file.store_buffer(body)
	zip_file.close()

	OS.move_to_trash(ProjectSettings.globalize_path("res://addons/pandora"))

	var zip_reader: ZIPReader = ZIPReader.new()
	zip_reader.open(TEMP_FILE_NAME)
	var files: PackedStringArray = zip_reader.get_files()

	var base_path = files[1]

	for path in files:
		var new_file_path: String = path.replace(base_path, "")
		if path.ends_with("/"):
			DirAccess.make_dir_recursive_absolute("res://addons/%s" % new_file_path)
		else:
			var file: FileAccess = FileAccess.open(
				"res://addons/%s" % new_file_path, FileAccess.WRITE
			)
			file.store_buffer(zip_reader.read_file(path))

	zip_reader.close()
	DirAccess.remove_absolute(TEMP_FILE_NAME)

	self.update_done.emit(true)
	self.hide()
