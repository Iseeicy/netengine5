class_name PlayerInput
extends EntityInput

#
#	Private Variables
#

## All known input actions underneath us
var _input_actions: Array[PlayerInputAction] = []

## All known analog inputs underneath us
var _input_analog: Array[PlayerInputAnalog] = []

## All known analog axis underneath us
var _input_axis: Array[PlayerInputAxis] = []

#
#	Godot Functions
#


func _ready():
	# Get all of our input actions
	_find_all_inputs(self, _input_actions, _input_analog, _input_axis)


#
#   Entity Input Functions
#


func gather_inputs(tick: EntityInput.TickType) -> void:
	super(tick)

	# Go through all of the inputs stored in `_input_actions` and
	# register them as our `EntityInput` inputs.
	for input in _input_actions:
		# If we actually had an input event on this frame, REGISTER IT!
		var state := input.get_input_state()
		if state != EntityInput.InputState.NONE:
			_register_input(input.name, state)

	for analog in _input_analog:
		_register_analog_input(analog.name, analog.get_analog_strength())

	for axis in _input_axis:
		_register_axis(
			axis.name, axis.negative_action.name, axis.positive_action.name
		)


#
#	Private Functions
#


func _find_all_inputs(
	starting_node: Node,
	found_actions: Array[PlayerInputAction],
	found_analog: Array[PlayerInputAnalog],
	found_axis: Array[PlayerInputAxis]
) -> void:
	if starting_node is PlayerInputAction:
		found_actions.append(starting_node)
	if starting_node is PlayerInputAnalog:
		found_analog.append(starting_node)
	if starting_node is PlayerInputAxis:
		found_axis.append(starting_node)

	for child in starting_node.get_children():
		_find_all_inputs(child, found_actions, found_analog, found_axis)
