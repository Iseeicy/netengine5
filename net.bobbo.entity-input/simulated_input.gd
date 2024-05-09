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

## Array[Dictionary<String, bool>]
## A queue of raw input states to supply when gathering inputs next.
var _queued_raw_states: Array[Dictionary]

## Dictionary<String, EntityInput.InputState>
## The current state of inputs to supply when gather_inputs is called.
var _current_states: Dictionary = {}

#
#   Entity Input Functions
#


func gather_inputs() -> void:
	super()
	# TODO - handle process & physics process

	_progress_current_states()  # Move the current input states forward.

	# Compare our queue'd raw states to the now updated current states, and
	# apply them!
	var next_states: Dictionary = _queued_raw_states.pop_front()
	if not next_states:
		return

	for action_name in next_states.keys():
		var current_state: EntityInput.InputState = _current_states.get(
			action_name, EntityInput.InputState.NONE
		)
		var should_be_pressed: bool = next_states[action_name]

		# Calculate what the next state should be given our current state and
		# desired button press state
		var next_state := _calculate_next_input_state(
			current_state, should_be_pressed
		)

		# If this action doesn't have a state anymore (it's unpressed), then
		# just remove it
		if next_state == EntityInput.InputState.NONE:
			_current_states.erase(action_name)
		# If the action DOES have a state, apply it!
		else:
			_current_states[action_name] = next_state


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
	# If there's not enough queue'd ticks of action for the next tick and the
	# tick after, add the dicts for em!
	while _queued_raw_states.size() < 2:
		_queued_raw_states.push_back({})

	# In the next tick, queue that our input is to be pressed
	_queued_raw_states[0][action_name] = true

	# In the tick AFTER the next tick, queue that our input is to be released
	_queued_raw_states[1][action_name] = false


## Simulate pressing a button down or releasing a button.
## Args:
##  `action_name`: The name of the Input Action to simulate.
##  `is_down`: Should we simulate the button being held down? Or released?
func simulate_action(action_name: String, is_down: bool) -> void:
	# If there's nothing in the queue of states for the next tick, make a dict
	# for it!
	if _queued_raw_states.size() < 1:
		_queued_raw_states.push_back({})

	# Int he next tick, queue our action
	_queued_raw_states[0][action_name] = is_down


#
#	Private Functions
#


## Go through `_current_states` and progress inputs in the following fashion:
## - JUST_DOWN -> PRESSED
## - JUST_UP -> removed from dict
func _progress_current_states() -> void:
	# Go through the current state and progress any inputs
	for action_name in _current_states.keys():
		var state: EntityInput.InputState = _current_states[action_name]

		# If this was just down, now it's pressed
		if state & EntityInput.InputState.JUST_DOWN:
			_current_states[action_name] = EntityInput.InputState.PRESSED
		# If this was just up, now it shouldn't be here
		elif state & EntityInput.InputState.JUST_UP:
			_current_states.erase(action_name)


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
