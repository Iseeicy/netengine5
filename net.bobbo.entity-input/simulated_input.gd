## A helper class that simulates inputs as an EntityInput. This means that you
## can write code triggering input events for things that would use
## EntityInput. This is super helpful for things like NPCs, which may want to
## trigger one-shot inputs without having to manually manipulate down / up
## events.
class_name SimulatedInput
extends EntityInput

#
#   Entity Input Functions
#


func gather_inputs() -> void:
	super()
	# TODO


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
	# TODO
	return


## Simulate pressing a button down or releasing a button.
## Args:
##  `action_name`: The name of the Input Action to simulate.
##  `is_down`: Should we simulate the button being held down? Or released?
func simulate_action(action_name: String, is_down: bool) -> void:
	# TODO
	return
