## An abstract class used to manage gathering inputs from some arbitrary
## source. Intended to be extended by `PlayerInput` and `SimulateInput`.
class_name EntityInput
extends Node

#
#   Classes
#


## Info defining how to read a specific axis
class AxisDefinition:
	var negative_action_name: String
	var positive_action_name: String


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

## Dictionary<String, AxisDefinition>
## The axis that this entity is providing on the current frame.
var _axis_inputs: Dictionary = {}

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
##	A value between 0 and 1.
func get_analog(action_name: String) -> float:
	return _analog_inputs.get(action_name, 0)


## Get the value of two analog inputs along a 1D axis.
## Args:
##	`axis_name`: The name of the axis to read.
## Returns:
##	A value between -1 and 1
func get_axis(axis_name: String) -> float:
	var axis: AxisDefinition = _axis_inputs.get(axis_name, null)
	if not axis:
		return 0

	return (
		get_analog(axis.positive_action_name)
		- get_analog(axis.negative_action_name)
	)


## Get a 2d axis input using the name of each axis.
## Args:
##	`x_axis_name`: The name of the X axis.
##	`Y_axis_name`: The name of the Y axis.
## Returns:
##	A normalized Vector2 containing both axis.
func get_axis_2d(x_axis_name: String, y_axis_name: String) -> Vector2:
	return Vector2(get_axis(x_axis_name), get_axis(y_axis_name)).normalized()


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


## Returns the direction that this entity wants to try and move in. This
## value is local to the entity's assumed facing direction, NOT a global
## direction. Example - if the entity wants to move forward, then this
## will be Vector3.FORWARD. Should be normalized.
## Returns:
##  `Vector3` - the target local movement direction.
func get_local_movement_dir() -> Vector3:
	return Vector3.ZERO


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


## Marks that an axis exists on this frame.
## Args:
##	`axis_name`: The name of the axis that register.
##	`negative_action_name`: The action that, when pressed all the way, pulls
##		this axis as far negative as possible.
##	`positive_action_name`: The action that, when pressed all the way, pushes
##		this axis as far positive as possible.
func _register_axis(
	axis_name: String,
	negative_action_name: String,
	positive_action_name: String
) -> void:
	var axis := AxisDefinition.new()
	axis.negative_action_name = negative_action_name
	axis.positive_action_name = positive_action_name
	_axis_inputs[axis_name] = axis


## Removes all saved input events from this frame. This should be
## performed at the end of each frame / tick to ensure that multiple
## inputs don't build up between frames.
func _sweep_inputs() -> void:
	_inputs.clear()
	_analog_inputs.clear()
	_axis_inputs.clear()
