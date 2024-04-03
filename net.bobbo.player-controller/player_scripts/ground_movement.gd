extends PlayerControllerScript

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
#	Functions
#


func character_agent_physics_process(delta: float) -> void:
	if not player.is_on_floor():
		return

	# Calculate our new velocity without vertical movement
	var target_vel = player.get_rotated_move_dir() * _get_move_speed() * delta
	var previous_vel = Vector3(player.velocity.x, 0, player.velocity.z)
	var accel = _calculate_acceleration(target_vel, previous_vel)

	var new_vel = previous_vel.move_toward(target_vel, delta * accel)
	player.velocity.x = new_vel.x
	player.velocity.z = new_vel.z


#
#	Private Functions
#


func _get_move_speed() -> float:
	if (
		agent_3d.input.is_action_pressed(CROUCH_ACTION)
		and player.is_on_floor()
	):
		return crouch_speed

	if agent_3d.input.is_action_pressed(RUN_ACTION):
		return run_speed

	return walk_speed


func _calculate_acceleration(target_vel: Vector3, prev_vel: Vector3) -> float:
	if target_vel.length_squared() > prev_vel.length_squared():
		return acceleration_rise

	return acceleration_fall
