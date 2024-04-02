class_name EntityInput
extends Node

#
#   Classes
#

## All of the possible states than input can be simultaniously. Used as
## bitflags.
enum InputState {
	NONE = 0,
	JUST_DOWN = 1 << 0,
	PRESSED = 1 << 1,
	JUST_UP = 1 << 2,
	PRESSED_OR_JUST_DOWN = 1 << 1 | 1 << 0
}

#
#	Private Variables
#

## Dictionary<String, InputState>
## The inputs that this entity is providing on the current frame.
var _inputs: Dictionary = {}

#
#	Public Functions
#


## Has the given action just STARTED being pressed on this frame?
## Args:
## 	`action_name`: The name of the action to check
## Returns:
## 	`true` if the given action was found and has just been started being
##		pressed on this frame.
##	`false` if the given action is not pressed.
func is_action_just_pressed(action_name: String) -> bool:
	var state = _inputs.get(action_name, InputState.NONE)
	return (state & InputState.JUST_DOWN) != InputState.NONE


## Is the given action actively being pressed / held down?
## Args:
## 	`action_name`: The name of the action to check
## Returns:
## 	`true` if the given action was found and is actively being pressed.
##		May hae been held down for many frames previously.
##	`false` if the given action is not pressed.
func is_action_pressed(action_name: String) -> bool:
	var state = _inputs.get(action_name, InputState.NONE)
	return (state & InputState.PRESSED_OR_JUST_DOWN) != InputState.NONE


## Has the given action just STOPPED being pressed on this frame?
## Args:
## 	`action_name`: The name of the action to check
## Returns:
## 	`true` if the given action was found and was just been released on
##		this frame.
##	`false` if the given action is pressed.
func is_action_just_released(action_name: String) -> bool:
	var state = _inputs.get(action_name, InputState.NONE)
	return (state & InputState.JUST_UP) != InputState.NONE


## Marks that an input event of some kind has happened on this frame.
## Args:
##	`action_name`: The name of the action to store an input for.
##	`state_flag`: The bitflag values of the input state to set for the
##		given action.
func register_input(action_name: String, state_flag: InputState) -> void:
	# Use bitwise operations to merge the registered flag into the
	# existing input state.
	var state = _inputs.get(action_name, InputState.NONE)
	_inputs[action_name] = state | state_flag


## Removes all saved input events from this frame. This should be
## performed at the end of each frame / tick to ensure that multiple
## inputs don't build up between frames.
func sweep_inputs() -> void:
	_inputs.clear()


#
#   Virtual Functions
#


## Returns the direction that this entity wants to try and move in. This
## value is local to the entity's assumed facing direction, NOT a global
## direction. Example - if the entity wants to move forward, then this
## will be Vector3.FORWARD. Should be normalized.
## Returns:
##  `Vector3` - the target local movement direction.
func get_local_movement_dir() -> Vector3:
	return Vector3.ZERO
