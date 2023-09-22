extends PlayerControllerScript

#
#	Exported
#

@export var walk_speed: float = 300
@export var run_speed: float = 500
@export var crouch_speed: float = 100
@export var acceleration_rise: float = 100
@export var acceleration_fall: float = 40

#
#	Variables
#

const move_forward_action: String = "player_move_forward"
const move_back_action: String = "player_move_back"
const move_left_action: String = "player_move_left"
const move_right_action: String = "player_move_right"
const run_action: String = "player_should_run"
const crouch_action: String = "player_crouch"

#
#	Functions
#

func player_ready():
	self.assert_input_action(move_forward_action)
	self.assert_input_action(move_back_action)
	self.assert_input_action(move_left_action)
	self.assert_input_action(move_right_action)
	self.assert_input_action(run_action)
	self.assert_input_action(crouch_action)

func player_physics_process(delta: float) -> void:
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
	if Input.is_action_pressed("player_crouch") and player.is_on_floor():
		return crouch_speed
	
	if Input.is_action_pressed("player_should_run"):
		return run_speed
	else:
		return walk_speed
	
func _calculate_acceleration(target_vel: Vector3, prev_vel: Vector3) -> float:
	if target_vel.length_squared() > prev_vel.length_squared():
		return acceleration_rise
	else:
		return acceleration_fall
	
