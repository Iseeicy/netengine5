class_name BobboState
extends Node

#
#	Signals
#

## Called when this state has been "completed". Up to the implementation of the
## state to determine how this is used. It is intended to allow sequences or
## routines to signal that they have been fulfilled.
signal completed

## Called when this state has been "cancelled". Up to the implementation of the
## state to determine how this is used. It is intended to allow sequences or
## routines to signal that they have been stopped or canceled before being
## fulfilled.
signal cancelled(reason: String)

#
#	Private Variables
#

var _is_active: bool = true
var _current_on_complete_func: Callable = Callable()
var _current_on_cancelled_func: Callable = Callable()

@onready var _parent_state: BobboState = _get_parent_state()
@onready var _state_machine: BobboStateMachine = _get_state_machine(self)
@onready var _state_path: String = _get_state_path(self)

#
#	Functions For State Machine
#


## A wrapper function intended for the parent state machine to call enter on
## this state and setup callbacks without making child implementations handle
## it.
func state_machine_call_state_enter(
	message: Dictionary = {},
	on_complete_callback: Callable = Callable(),
	on_cancelled_callback: Callable = Callable()
) -> void:
	# Cache the callbacks & connect them to our signals
	_current_on_complete_func = on_complete_callback
	_current_on_cancelled_func = on_cancelled_callback
	if _current_on_complete_func.is_valid():
		completed.connect(_current_on_complete_func.bind())
	if _current_on_cancelled_func.is_valid():
		cancelled.connect(_current_on_cancelled_func.bind())

	# Delegate implementation to extending classes
	state_enter(message)


## A wrapper function intended for the parent state machine to call exit on
## this state and cleanup callbacks without making the child implementation
## handle it.
func state_machine_call_state_exit() -> void:
	# Delegate implementation to extending classes
	state_exit()

	# Disconnect the callbacks from our signals
	if _current_on_complete_func.is_valid():
		completed.disconnect(_current_on_complete_func.bind())
		_current_on_complete_func = Callable()
	if _current_on_cancelled_func.is_valid():
		cancelled.disconnect(_current_on_cancelled_func.bind())
		_current_on_cancelled_func = Callable()


#
#	Public Functions
#


func state_enter(_message := {}) -> void:
	return


func state_unhandled_input(_event: InputEvent) -> void:
	return


func state_process(_delta: float) -> void:
	return


func state_physics_process(_delta: float) -> void:
	return


func state_exit() -> void:
	return


func get_state_path() -> String:
	return _state_path


func set_is_active(should_be_active: bool) -> void:
	_is_active = should_be_active
	set_block_signals(!_is_active)


func get_is_active() -> bool:
	return _is_active


#
#	Private Functions
#


# Get the state from our parent, or null if there is none
func _get_parent_state() -> BobboState:
	# If the parent is not a player state, this will be null
	return get_parent() as BobboState


# Recursively climb the tree to get the state machine that
# we belong to
func _get_state_machine(node: Node) -> Node:
	if node == null or node is BobboStateMachine:
		return node
	return _get_state_machine(node.get_parent())


func _get_state_path(node: Node) -> String:
	if node == null or node is BobboStateMachine:
		return ""

	var rest_of_path = _get_state_path(node.get_parent())
	if rest_of_path == "":
		return node.name

	return rest_of_path + "/" + node.name
