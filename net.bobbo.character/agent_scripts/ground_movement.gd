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

## Is the entity trying to crouch right now?
var _should_crouch: bool = false

## Is the entity trying to run right now?
var _should_run: bool = false

#
#	Functions
#


func character_agent_process(_delta: float) -> void:
	# Cache our input in process so we can use it in physics_process
	_should_crouch = agent_3d.input.is_action_pressed(CROUCH_ACTION)
	_should_run = agent_3d.input.is_action_pressed(RUN_ACTION)


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
	# Rotate the input to match facing dir
	return agent_3d.input.get_local_movement_dir().rotated(
		Vector3.UP, agent_3d.playermodel_pivot.rotation.y
	)


func _get_move_speed() -> float:
	if _should_crouch and agent_3d.is_on_floor():
		return crouch_speed

	if _should_run:
		return run_speed

	return walk_speed


func _calculate_acceleration(target_vel: Vector3, prev_vel: Vector3) -> float:
	if target_vel.length_squared() > prev_vel.length_squared():
		return acceleration_rise

	return acceleration_fall
