## Allows an agent to move while on the ground.
extends CharacterAgentScript

#
#	Constants
#

const RUN_ACTION: String = "player_should_run"
const CROUCH_ACTION: String = "player_crouch"

#
#	Exported
#

@export var walk_speed: float = 300
@export var run_speed: float = 500
@export var crouch_speed: float = 100
@export var acceleration_rise: float = 100
@export var acceleration_fall: float = 40

#
#	Private Variables
#

## An input wrapper to make getting the movement axis easier
var _move_axis: InputAxis2d = InputAxis2d.new(
	InputAxis1d.new("player_move_left", "player_move_right"),
	InputAxis1d.new("player_move_forward", "player_move_back")
)

## Is the entity trying to crouch right now?
var _should_crouch: bool = false

## Is the entity trying to run right now?
var _should_run: bool = false

#
#	Functions
#


func character_agent_physics_process(delta: float) -> void:
	if not agent_3d.is_on_floor():
		return

	# Calculate our new velocity without vertical movement
	var target_vel = _get_rotated_movement_dir() * _get_move_speed() * delta
	var previous_vel = Vector3(agent_3d.velocity.x, 0, agent_3d.velocity.z)
	var accel = _calculate_acceleration(target_vel, previous_vel)

	var new_vel = previous_vel.move_toward(target_vel, delta * accel)
	agent_3d.velocity.x = new_vel.x
	agent_3d.velocity.z = new_vel.z


#
#	Private Functions
#


func _get_rotated_movement_dir() -> Vector3:
	var movement_input = agent_3d.input.read_axis_2d(_move_axis).normalized()

	# Rotate the input to match facing dir
	return Vector3(movement_input.x, 0, movement_input.y).rotated(
		Vector3.UP, agent_3d.playermodel_pivot.rotation.y
	)


func _get_move_speed() -> float:
	var should_crouch = agent_3d.input.is_action_pressed(CROUCH_ACTION)
	var should_run = agent_3d.input.is_action_pressed(RUN_ACTION)

	if should_crouch and agent_3d.is_on_floor():
		return crouch_speed

	if should_run:
		return run_speed

	return walk_speed


func _calculate_acceleration(target_vel: Vector3, prev_vel: Vector3) -> float:
	if target_vel.length_squared() > prev_vel.length_squared():
		return acceleration_rise

	return acceleration_fall
