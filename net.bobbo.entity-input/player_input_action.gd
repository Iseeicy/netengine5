## A node representation of some configurable player input action.
## Making this node based means we can allow a designer in Godot to
## define what Input Actions should be listened for IN EDITOR, rather
## than modifying code.
class_name PlayerInputAction
extends Node

#
#   Exports
#

## The name of the action to listen for, in Godot's InputMap.
@export var action_name: String = "SET_ME"

#
#   Public Functions
#


## Get the input state for our input action.
func get_input_state() -> EntityInput.InputState:
	var state := EntityInput.InputState.NONE

	# If this action doesn't exist, EXIT EARLY
	if not InputMap.has_action(action_name):
		return state

	# Manipulate the state according to actual user input
	if Input.is_action_just_pressed(action_name):
		state = state | EntityInput.InputState.JUST_DOWN
	if Input.is_action_pressed(action_name):
		state = state | EntityInput.InputState.PRESSED
	if Input.is_action_just_released(action_name):
		state = state | EntityInput.InputState.JUST_UP

	return state
