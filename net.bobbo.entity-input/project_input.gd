## A helper class that assists with programatically adding new inputs
## and events to the InputMap
@tool
class_name ProjectInput
extends RefCounted

#
#   Public Variables
#

## The name / key of the action that we are mapping with this class.
var action_name: String

#
#   Godot Functions
#


func _init(action_name: String):
	self.action_name = action_name

	# If we don't have this input in the project settings yet, add it!
	if not ProjectSettings.has_setting(get_setting_name(action_name)):
		ProjectSettings.set_setting(
			get_setting_name(action_name), {"deadzone": 0.5, "events": []}
		)


#
#	Public Static Functions
#


static func remove(action_name: String) -> void:
	if ProjectSettings.has_setting(get_setting_name(action_name)):
		ProjectSettings.set_setting(get_setting_name(action_name), null)


static func get_setting_name(action_name: String) -> String:
	return "input/%s" % action_name


#
#   Public Functions
#


func bind_keycode(
	physical_keycode: int, options: Dictionary = {}
) -> ProjectInput:
	# Create the event that corresponds to the given keycode
	var key = InputEventKey.new()
	key.physical_keycode = physical_keycode
	key.shift_pressed = options.get("shift_pressed", false)
	key.alt_pressed = options.get("alt_pressed", false)
	key.ctrl_pressed = options.get("ctrl_pressed", false)
	key.meta_pressed = options.get("meta_pressed", false)

	# Add to map
	_add_event_to_settings(key)
	return self


func bind_mouse_button(button_index: MouseButton) -> ProjectInput:
	# Create the event that corresponds to the given mouse button
	var key = InputEventMouseButton.new()
	key.button_index = button_index

	# Add to map
	_add_event_to_settings(key)
	return self


#
#	Private Functions
#


func _add_event_to_settings(event: InputEvent) -> void:
	# Get the events array for this setting
	var events: Array = (
		ProjectSettings.get_setting(get_setting_name(action_name)).events
	)

	# Add the event
	events.push_back(event)
