@tool
class_name BobboStateMachine
extends Node

#
#	Exports
#

signal transitioned(state: BobboState, path: String)
signal active_changed(is_active: bool)

@export var initial_state: NodePath:
	get:
		return initial_state
	set(value):
		initial_state = value
		update_configuration_warnings()

#
#	Public Variables
#

var state: BobboState = null

#
#	Private Variables
#

var _is_active: bool = true

#
#	Godot Functions
#


func _ready():
	if Engine.is_editor_hint():
		return

	# Populate the initial state
	assert(initial_state != null)
	state = get_node(initial_state) as BobboState

	# Enter the inital state
	active_changed.emit(true)
	state.state_enter()
	transitioned.emit(state, state.get_state_path())


func _get_configuration_warnings():
	var warnings: Array[String] = []
	if not initial_state:
		warnings.append("Initial State must be assigned.")
	return warnings


# Delegate input to the currently active state
func _unhandled_input(event):
	if not state:
		return
	state.state_unhandled_input(event)


# Delegate an update to the currently active state
func _process(delta):
	if not state:
		return
	state.state_process(delta)


# Delegate a physics update to the currently active state
func _physics_process(delta):
	if not state:
		return
	state.state_physics_process(delta)


#
#	Public Functions
#


# Transition between active states.
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


func set_is_active(should_be_active: bool) -> void:
	if _is_active == should_be_active:
		return

	_is_active = should_be_active
	set_process(should_be_active)
	set_physics_process(should_be_active)
	set_process_unhandled_input(should_be_active)
	state.set_is_active(should_be_active)
	active_changed.emit(_is_active)


func get_is_active() -> bool:
	return _is_active
