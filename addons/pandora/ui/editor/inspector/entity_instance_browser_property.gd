extends EditorProperty


# The main control for editing the property.
var property_control = Button.new()
# An internal value of the property.
var current_value = 0
# A guard against internal changes when the property is updated.
var updating = false


func _init(type:String) -> void:
	# Add the control as a direct child of EditorProperty node.
	add_child(property_control)
	# Make sure the control is able to retain the focus.
	add_focusable(property_control)
	# Setup the initial state and connect to the signal to track changes.
	refresh_control_text()
	property_control.pressed.connect(_on_button_pressed)


func _on_button_pressed():
	# Ignore the signal if the property is currently being updated.
	if (updating):
		return

	# Generate a new random integer between 0 and 99.
	current_value = randi() % 100
	refresh_control_text()
	emit_changed(get_edited_property(), current_value)


func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	if (new_value == current_value):
		return

	# Update the control with the new value.
	updating = true
	current_value = new_value
	refresh_control_text()
	updating = false

func refresh_control_text():
	property_control.text = "Value: " + str(current_value)
