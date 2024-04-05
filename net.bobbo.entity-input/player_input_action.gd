## A node representation of some configurable player input action.
## Making this node based means we can allow a designer in Godot to
## define what Input Actions should be listened for IN EDITOR, rather
## than modifying code.
## The name of this node should be the name of the Input Action to use.
@tool
class_name PlayerInputAction
extends Node

#
#   Public Functions
#


## Get the input state for our input action.
func get_input_state() -> EntityInput.InputState:
	var state := EntityInput.InputState.NONE

	# If this action doesn't exist, EXIT EARLY
	if not InputMap.has_action(name):
		return state

	# Manipulate the state according to actual user input
	if Input.is_action_just_pressed(name):
		state = state | EntityInput.InputState.JUST_DOWN
	if Input.is_action_pressed(name):
		state = state | EntityInput.InputState.PRESSED
	if Input.is_action_just_released(name):
		state = state | EntityInput.InputState.JUST_UP

	return state
