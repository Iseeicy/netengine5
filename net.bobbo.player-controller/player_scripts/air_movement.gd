extends PlayerControllerScript

#
#	Exported
#

@export var move_speed: float = 150
@export var acceleration: float = 20

#
#	Functions
#


func character_agent_physics_process(delta: float) -> void:
	if agent_3d.is_on_floor():
		return

	if agent_3d.input.get_local_movement_dir() == Vector3.ZERO:
		return

	var target_vel = (
		_get_rotated_movement_dir() * _get_move_speed(delta) * delta
	)
	var previous_vel = Vector3(agent_3d.velocity.x, 0, agent_3d.velocity.z)
	var new_vel = previous_vel.move_toward(target_vel, delta * acceleration)
	agent_3d.velocity.x = new_vel.x
	agent_3d.velocity.z = new_vel.z


#
#	Private Functions
#


func _get_rotated_movement_dir() -> Vector3:
	# Rotate the input to match facing dir
	return agent_3d.input.get_local_movement_dir().rotated(
		Vector3.UP, agent_3d.playermodel_pivot.rotation.y
	)


func _get_move_speed(delta: float) -> float:
	# Calculate the speed we're already moving at
	var previous_vel = Vector3(agent_3d.velocity.x, 0, agent_3d.velocity.z)
	var current_move_speed = previous_vel.length() / delta

	# If we're currently moving at a speed greater than our target,
	# then just use that speed
	if current_move_speed > move_speed:
		return current_move_speed

	return move_speed
