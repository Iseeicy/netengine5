## A helper class that assists with programatically adding new inputs
## and events to the InputMap
class_name InputMapper
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

	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	print("Mapping %s" % action_name)


#
#	Public Static Functions
#


static func remove(action_name: String) -> void:
	if InputMap.has_action(action_name):
		InputMap.erase_action(action_name)


#
#   Public Functions
#


func bind_keycode(
	physical_keycode: int, options: Dictionary = {}
) -> InputMapper:
	# Create the event that corresponds to the given keycode
	var key = InputEventKey.new()
	key.physical_keycode = physical_keycode
	key.shift_pressed = options.get("shift_pressed", false)
	key.alt_pressed = options.get("alt_pressed", false)
	key.ctrl_pressed = options.get("ctrl_pressed", false)
	key.meta_pressed = options.get("meta_pressed", false)

	# Add to map
	InputMap.action_add_event(action_name, key)
	return self


func bind_mouse_button(button_index: MouseButton) -> InputMapper:
	# Create the event that corresponds to the given mouse button
	var key = InputEventMouseButton.new()
	key.button_index = button_index

	# Add to map
	InputMap.action_add_event(action_name, key)
	return self
