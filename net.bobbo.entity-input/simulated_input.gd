## A helper class that simulates inputs as an EntityInput. This means that you
## can write code triggering input events for things that would use
## EntityInput. This is super helpful for things like NPCs, which may want to
## trigger one-shot inputs without having to manually manipulate down / up
## events.
class_name SimulatedInput
extends EntityInput

#
#   Private Variables
#

## Dictionary<
##	EntityInput.TickType,
##	Array<
##		Dictionary<
##			String,
##			bool>>>
## A dictionary that stores a queue of raw states, by the tick type they belong
## to. We store these by tick type, because then we can suppport using this
## across the update tick AND the physics tick.
var _queued_raw_states_by_tick_type: Dictionary = {
	EntityInput.TickType.PROCESS: [] as Array[Dictionary],
	EntityInput.TickType.PROCESS_PHYSICS: [] as Array[Dictionary]
}

## Dictionary<
##	EntityInput.TickType,
##	Dictionary<
##		String,
##		EntityInput.InputState>>
## A dictionary that stores the current state of inputs to supply when
## gather_inputs is called, by the tick type that they belong to. We store
## these by tick type, because then we can suppport using this across the
## update tick AND the physics tick.
var _current_states_by_tick_type: Dictionary = {
	EntityInput.TickType.PROCESS: {}, EntityInput.TickType.PROCESS_PHYSICS: {}
}

## Dictionary<
##	EntityInput.TickType,
##	Dictionary<
##		String,
##		float>>
## A dictionary that stores the current state of ANALOG input values to supply
## when gather_inputs is called, by the tick type that they belong to. We store
## these by tick type, because then we can suppport using this across the
## update tick AND the physics tick.
var _current_analog_by_tick_type: Dictionary = {
	EntityInput.TickType.PROCESS: {}, EntityInput.TickType.PROCESS_PHYSICS: {}
}

#
#   Entity Input Functions
#


func gather_inputs(tick: EntityInput.TickType) -> void:
	super(tick)

	# Move the current input states forward.
	_progress_states(_current_states_by_tick_type[tick])

	# Apply the latest states to our current state dict, if there are any
	if _queued_raw_states_by_tick_type[tick].size() > 0:
		_apply_raw_states(
			_current_states_by_tick_type[tick],
			_queued_raw_states_by_tick_type[tick].pop_front()
		)

	# Register our current inputs
	for action_name in _current_states_by_tick_type[tick].keys():
		var state = _current_states_by_tick_type[tick][action_name]
		_register_input(action_name, state)

	# Register our analog values
	for action_name in _current_analog_by_tick_type[tick].keys():
		var value = _current_analog_by_tick_type[tick][action_name]
		_register_analog_input(action_name, value)


#
#   Public Functions
#


## Simulate quickly pressing a button and then releasing it. Marks the input as
## down, and then up on the next frame.
## Args:
##  `action_name`: The name of the Input Action to simulate.
func simulate_action_oneshot(action_name: String) -> void:
	# Simulate the oneshot for all tick types
	for tick_type in EntityInput.TickType.values():
		_simulate_action_oneshot(
			_queued_raw_states_by_tick_type[tick_type], action_name
		)


## Simulate pressing a button down or releasing a button.
## Args:
##  `action_name`: The name of the Input Action to simulate.
##  `is_down`: Should we simulate the button being held down? Or released?
func simulate_action(action_name: String, is_down: bool) -> void:
	# Simulate the action for all tick types
	for tick_type in EntityInput.TickType.values():
		_simulate_action(
			_queued_raw_states_by_tick_type[tick_type], action_name, is_down
		)


## Simulate some analog input's strength.
## Args:
##	`action_name`: The name of the Input Action to simulate analog values for.
##	`strength`: The strength of analog force to simulate. Should be between 0
##		and 1 inclusive.
func simulate_analog(action_name: String, strength: float) -> void:
	# Simulate the analog force for all tick types
	for tick_type in EntityInput.TickType.values():
		_simulate_analog(
			_current_analog_by_tick_type[tick_type], action_name, strength
		)


## Simulate some 1d analog axis.
## Args:
##	`axis`: The axis to simulate an input for.
##	`value`: The value to assign to the axis. Should be between -Infinity and
##		Infinity.
func simulate_axis_1d(axis: InputAxis1d, value: float) -> void:
	if value > 0:
		simulate_analog(axis.positive_action_name, value)
		simulate_analog(axis.negative_action_name, 0)
	else:
		simulate_analog(axis.positive_action_name, 0)
		simulate_analog(axis.negative_action_name, -value)


## Simulate some 2d analog axis.
## Args:
##	`axis`: The axis to simulate and input for.
##	`value`: The ablue to assign to the axis.
func simulate_axis_2d(axis: InputAxis2d, value: Vector2) -> void:
	simulate_axis_1d(axis.x, value.x)
	simulate_axis_1d(axis.y, value.y)


#
#	Private Functions
#


## Queue agnostic implementation of simulate_action_oneshot
func _simulate_action_oneshot(
	raw_state_queue: Array[Dictionary], action_name: String
) -> void:
	# If there's not enough queue'd ticks of action for the next tick and the
	# tick after, add the dicts for em!
	while raw_state_queue.size() < 2:
		raw_state_queue.push_back({})

	# In the next tick, queue that our input is to be pressed
	raw_state_queue[0][action_name] = true

	# In the tick AFTER the next tick, queue that our input is to be released
	raw_state_queue[1][action_name] = false


## Queue agnostic implementation of simulate_action
func _simulate_action(
	raw_state_queue: Array[Dictionary], action_name: String, is_down: bool
) -> void:
	# If there's nothing in the queue of states for the next tick, make a dict
	# for it!
	if raw_state_queue.size() < 1:
		raw_state_queue.push_back({})

	# In the next tick, queue our action
	raw_state_queue[0][action_name] = is_down


## Queue agnostic implementation of simulate_analog
func _simulate_analog(
	raw_analog_values: Dictionary, action_name: String, strength: float
) -> void:
	raw_analog_values[action_name] = strength


## Go through a dictionary of states and progress inputs in the
## following fashion:
## - JUST_DOWN -> PRESSED
## - JUST_UP -> removed from dict
## Args:
##	`states`: Dictionary<String, EntityInput.InputState>
func _progress_states(states: Dictionary) -> void:
	# Go through the current state and progress any inputs
	for action_name in states.keys():
		var state: EntityInput.InputState = states[action_name]

		# If this was just down, now it's pressed
		if state & EntityInput.InputState.JUST_DOWN:
			states[action_name] = EntityInput.InputState.PRESSED
		# If this was just up, now it shouldn't be here
		elif state & EntityInput.InputState.JUST_UP:
			states.erase(action_name)


## Apply a dictionary of raw button states to a dictionary of action states,
## making sure to update stuff like JUST_DOWN and JUST_UP correctly.
func _apply_raw_states(states: Dictionary, raw_states: Dictionary) -> void:
	if not raw_states:
		return

	for action_name in raw_states.keys():
		var current_state: EntityInput.InputState = states.get(
			action_name, EntityInput.InputState.NONE
		)
		var should_be_pressed: bool = raw_states[action_name]

		# Calculate what the next state should be given our current state and
		# desired button press state
		var next_state := _calculate_next_input_state(
			current_state, should_be_pressed
		)

		# If this action doesn't have a state anymore (it's unpressed), then
		# just remove it
		if next_state == EntityInput.InputState.NONE:
			states.erase(action_name)
		# If the action DOES have a state, apply it!
		else:
			states[action_name] = next_state


## Given some input state, calculate it's next state given a raw bool of
## whether the button should be actively pressed or not.
func _calculate_next_input_state(
	current_state: EntityInput.InputState, should_be_pressed: bool
) -> EntityInput.InputState:
	# If we don't have a state for this yet...
	if current_state == EntityInput.InputState.NONE:
		if should_be_pressed:
			return EntityInput.InputState.JUST_DOWN
		return EntityInput.InputState.NONE

	# If the button was pressed and isn't anymore...
	if (
		(current_state & EntityInput.InputState.PRESSED_OR_JUST_DOWN)
		and not should_be_pressed
	):
		return EntityInput.InputState.JUST_UP

	# If the button wasn't pressed and IS now...
	if (
		not (current_state & EntityInput.InputState.PRESSED_OR_JUST_DOWN)
		and should_be_pressed
	):
		return EntityInput.InputState.JUST_DOWN

	# OTHERWISE - the state just stays
	return current_state
