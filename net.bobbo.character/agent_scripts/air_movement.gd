## Allows an agent to move while in the air.
extends CharacterAgentScript

#
#	Exported
#

@export var move_speed: float = 150
@export var acceleration: float = 20

#
#	Private Variables
#

## An input wrapper to make getting the movement axis easier
var _move_axis: InputAxis2d = null

#
#	Functions
#


func character_agent_ready() -> void:
	_move_axis = InputAxis2d.new(
		InputAxis1d.new("player_move_left", "player_move_right"),
		InputAxis1d.new("player_move_back", "player_move_forward")
	)


func character_agent_physics_process(delta: float) -> void:
	if agent_3d.is_on_floor():
		return

	if agent_3d.input.read_axis_2d(_move_axis) == Vector2.ZERO:
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
	var movement_input = agent_3d.input.read_axis_2d(_move_axis)

	# Rotate the input to match facing dir
	return Vector3(movement_input.x, 0, -movement_input.y).rotated(
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
