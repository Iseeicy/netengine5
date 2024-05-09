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
