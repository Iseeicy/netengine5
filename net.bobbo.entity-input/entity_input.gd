## An abstract class used to manage gathering inputs from some arbitrary
## source. Intended to be extended by `PlayerInput` and `SimulateInput`.
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

## What kind of tick to reference.
enum TickType { PROCESS, PROCESS_PHYSICS }

#
#	Private Variables
#

## Dictionary<String, InputState>
## The inputs that this entity is providing on the current frame.
var _inputs: Dictionary = {}

## Dictionary<String, float>
## The analog inputs that this entity is providing on the current frame.
var _analog_inputs: Dictionary = {}

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


## Get the value of some analog input on this frame.
## Args:
##	`action_name`: The name of the analog input to read.
## Returns:
##	A value between 0 and 1. If the action can't be found, this will always be
##	0.
func get_analog(action_name: String) -> float:
	return _analog_inputs.get(action_name, 0)


## Reads the value of some 1D axis.
## Args:
##	`axis`: The definition of the axis to read
## Returns:
##  A value from -1 to 1, inclusive.
func read_axis_1d(axis: InputAxis1d) -> float:
	return (
		get_analog(axis.positive_action_name)
		- get_analog(axis.negative_action_name)
	)


## Reads the value of some 2D axis.
## Args:
##	`axis`: The definition of the axis to read
## Returns:
##  A normalized Vector2.
func read_axis_2d(axis: InputAxis2d) -> Vector2:
	return Vector2(read_axis_1d(axis.x), read_axis_1d(axis.y)).normalized()


#
#   Virtual Functions
#


## Gathers all inputs from our input source, and clears previously
## gathered inputs. This should be called on the beginning of each
## _process tick & _physics_process tick by the node that uses this
## class.
func gather_inputs(_tick: TickType) -> void:
	_sweep_inputs()
	# This should be implemented by child classes!


#
#	Private Functions
#


## Marks that an button input event of some kind has happened on this frame.
## Args:
##	`action_name`: The name of the action to store an input for.
##	`state_flag`: The bitflag values of the input state to set for the
##		given action.
func _register_input(action_name: String, state_flag: InputState) -> void:
	# Use bitwise operations to merge the registered flag into the
	# existing input state.
	var state = _inputs.get(action_name, InputState.NONE)
	_inputs[action_name] = state | state_flag


## Marks that an analog input event of some kind has happened on this frame.
## Args:
##	`action_name`: The name of the analog action to store a strength for.
##	`strength`: The strength of the given input.
func _register_analog_input(action_name: String, strength: float) -> void:
	_analog_inputs[action_name] = strength


## Removes all saved input events from this frame. This should be
## performed at the end of each frame / tick to ensure that multiple
## inputs don't build up between frames.
func _sweep_inputs() -> void:
	_inputs.clear()
	_analog_inputs.clear()
