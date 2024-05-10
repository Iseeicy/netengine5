class_name PlayerInput
extends EntityInput

#
#	Private Variables
#

## Dictionary<String, PlayerInputAction>
## Stores each child input action using the action name as it's key.
var _input_actions: Dictionary = {}

#
#	Godot Functions
#


func _ready():
	# Get all of our input actions
	var found_inputs: Array[PlayerInputAction] = []
	_find_all_inputs(self, found_inputs)
	for child in found_inputs:
		_input_actions[child.name] = child


#
#   Entity Input Functions
#


func gather_inputs(tick: EntityInput.TickType) -> void:
	super(tick)

	# Go through all of the inputs stored in `_input_actions` and
	# register them as our `EntityInput` inputs.
	for input in _input_actions.values():
		var action_name: String = input.name
		var state: EntityInput.InputState = input.get_input_state()

		# If we actually had an input event on this frame, REGISTER IT!
		if state != EntityInput.InputState.NONE:
			_register_input(action_name, state)


func get_local_movement_dir() -> Vector3:
	# TODO - this should support analog at some point
	# TODO - should this be using our input action nodes...?
	var input = Vector3.ZERO

	# If the player isn't focused, don't read input
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return input

	if Input.is_action_pressed("player_move_forward"):
		input += Vector3.FORWARD
	if Input.is_action_pressed("player_move_back"):
		input -= Vector3.FORWARD
	if Input.is_action_pressed("player_move_left"):
		input += Vector3.LEFT
	if Input.is_action_pressed("player_move_right"):
		input -= Vector3.LEFT

	if input != Vector3.ZERO:
		input = input.normalized()

	return input


#
#	Private Functions
#


func _find_all_inputs(
	starting_node: Node, results: Array[PlayerInputAction]
) -> void:
	if starting_node is PlayerInputAction:
		results.append(starting_node)

	for child in starting_node.get_children():
		_find_all_inputs(child, results)
