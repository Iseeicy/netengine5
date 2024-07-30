class_name BobboStateMachine
extends Node

#
#	Exports
#

## Emitted when this state machine transitions to a new state.
signal transitioned(state: BobboState, path: String)

## Emitted when `set_is_active` is called with a new value.
signal active_changed(is_active: bool)

## The state that this state machine should start with, when ready.
@export var initial_state: NodePath

#
#	Public Variables
#

## The currently active state.
var state: BobboState

#
#	Private variables
#

## Is this state machine active?
var _is_active: bool = true

#
#	Public Functions
#


## Transition out of the current state and into a new state.
## Calls `state_exit()` on the current state, and `state_enter()` on the new
## state.
##
## Args:
##	`target_state_path`: The path of the state to transition to, relative to
##		this state machine.
##	`message`: OPTIONAL - a dictionary to pass to the new state, when
##		`state_enter()` is called.
func transition_to(
	target_state_path: String, message: Dictionary = {}
) -> void:
	# Convert the state path to an actual state. If there's no valid state there, EXIT
	var target_state = get_node_or_null(target_state_path) as BobboState
	if target_state == null:
		return

	state.state_exit()  # Exit the current state
	state = target_state  # Set the state w/ setter, to be safe
	state.state_enter(message)  # Enter the new state
	transitioned.emit(state, target_state_path)  # ...and tell us about it!


## Make this state machine and its states active or in-active.
##
## Args:
##	`should_be_active`: True if the state machine should become active, false
##		if it should become in-active.
func set_is_active(should_be_active: bool) -> void:
	if _is_active == should_be_active:
		return

	_is_active = should_be_active
	set_process(should_be_active)
	set_physics_process(should_be_active)
	set_process_unhandled_input(should_be_active)
	state.set_is_active(should_be_active)
	active_changed.emit(_is_active)


## Is this state machine and its states active, or inactive?
func get_is_active() -> bool:
	return _is_active


#
#	Private Functions
#


func _ready():
	assert(initial_state != null)
	state = get_node(initial_state) as BobboState

	# Enter the inital state
	active_changed.emit(true)
	state.state_enter()
	transitioned.emit(state, state.get_state_path())


# Delegate input to the currently active state
func _unhandled_input(event):
	state.state_unhandled_input(event)


# Delegate an update to the currently active state
func _process(delta):
	state.state_process(delta)


# Delegate a physics update to the currently active state
func _physics_process(delta):
	state.state_physics_process(delta)
