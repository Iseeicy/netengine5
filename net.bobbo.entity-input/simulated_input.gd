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
	EntityInput.TickType.PROCESS: [], EntityInput.TickType.PROCESS_PHYSICS: []
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

#
#   Entity Input Functions
#


func gather_inputs(tick: EntityInput.TickType) -> void:
	super(tick)

	# Move the current input states forward.
	_progress_states(_current_states_by_tick_type[tick])

	# Apply the latest states to our current state dict
	_apply_raw_states(
		_current_states_by_tick_type[tick],
		_queued_raw_states_by_tick_type[tick].pop_front()
	)


func get_local_movement_dir() -> Vector3:
	super()
	# TODO
	return Vector3.ZERO


#
#   Public Functions
#


## Simulate quickly pressing a button and then releasing it. Marks the input as
## down, and then up on the next frame.
## Args:
##  `action_name`: The name of the Input Action to simulate.
func simulate_action_oneshot(action_name: String) -> void:
	# Simulate the oneshot for all tick types
	for tick_type in EntityInput.TickType.keys():
		_simulate_action_oneshot(
			_queued_raw_states_by_tick_type[tick_type], action_name
		)


## Simulate pressing a button down or releasing a button.
## Args:
##  `action_name`: The name of the Input Action to simulate.
##  `is_down`: Should we simulate the button being held down? Or released?
func simulate_action(action_name: String, is_down: bool) -> void:
	# Simulate the action for all tick types
	for tick_type in EntityInput.TickType.keys():
		_simulate_action(
			_queued_raw_states_by_tick_type[tick_type], action_name, is_down
		)


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

	# Int he next tick, queue our action
	raw_state_queue[0][action_name] = is_down


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
