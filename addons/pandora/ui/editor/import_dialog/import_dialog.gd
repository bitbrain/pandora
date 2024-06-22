@tool
extends Control

signal import_started(import_count: int)
signal import_ended(data: Array[PandoraEntity])

@onready var notification_dialog = %NotificationDialog
@onready var confirmation_dialog = %ConfirmationDialog
@onready var file_dialog = %FileDialog


func _ready():
	file_dialog.file_selected.connect(_import_file)
	Pandora.import_success.connect(self._on_import_success)
	Pandora.import_failed.connect(self._on_import_failed)
	Pandora.import_calculation_ended.connect(self._on_import_calculation_ended)
	Pandora.import_calculation_failed.connect(self._on_import_calculation_failed)


func open():
	file_dialog.popup_centered()


func _import_file(path: String) -> void:
	Pandora.calculate_import_data(path)


func _on_import_calculation_failed(reason: String) -> void:
	notification_dialog.title = "Import Failed!"
	notification_dialog.dialog_text = reason
	notification_dialog.popup_centered()


func _on_import_calculation_ended(import_info: Dictionary) -> void:
	confirmation_dialog.title = "Confirm Import"
	confirmation_dialog.dialog_text = (
		"Found "
		+ str(import_info["total_categories"])
		+ " Categories with "
		+ str(import_info["total_entities"])
		+ " Entities. Would you like to proceed?"
	)
	confirmation_dialog.confirmed.connect(func(): self._start_import(import_info))
	confirmation_dialog.popup_centered()


func _start_import(import_info: Dictionary) -> void:
	import_started.emit(
		(
			int(import_info["total_categories"])
			+ int(import_info["total_entities"])
			+ int(import_info["total_properties"])
		)
	)
	Pandora.import_data(import_info["path"])


func _on_import_success(imported_count: int = 0) -> void:
	var data: Array[PandoraEntity] = []
	data.assign(Pandora.get_all_roots())
	notification_dialog.title = "Import Finished!"
	notification_dialog.dialog_text = str(imported_count) + " records imported successfully!"
	notification_dialog.popup_centered()
	import_ended.emit(data)


func _on_import_failed(reason: String) -> void:
	notification_dialog.title = "Import Failed!"
	notification_dialog.dialog_text = reason
	notification_dialog.popup_centered()
