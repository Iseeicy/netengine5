extends Node
class_name BobboState

@onready var _parent_state: BobboState = _get_parent_state()
@onready var _state_machine: BobboStateMachine = _get_state_machine(self)
@onready var _state_path: String = _get_state_path(self)
var _is_active: bool = true

#
#	Public Functions
#

func state_enter(_message: Dictionary = {}) -> void:
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
	else:
		return _get_state_machine(node.get_parent())

func _get_state_path(node: Node) -> String:
	if node == null or  node is BobboStateMachine:
		return ""
	else:
		var rest_of_path = _get_state_path(node.get_parent())
		if rest_of_path == "":
			return node.name
		else:
			return rest_of_path + "/" + node.name
