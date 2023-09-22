extends PlayerControllerScript

#
#	Exported
#

@export var move_speed: float = 150
@export var acceleration: float = 20

#
#	Functions
#

func player_physics_process(delta: float) -> void:
	if player.is_on_floor():
		return
	
	if player.get_movement_dir() == Vector3.ZERO:
		return
	
	var target_vel = player.get_rotated_move_dir() * _get_move_speed(delta) * delta
	var previous_vel = Vector3(player.velocity.x, 0, player.velocity.z)
	var new_vel = previous_vel.move_toward(target_vel, delta * acceleration)
	player.velocity.x = new_vel.x
	player.velocity.z = new_vel.z
	
#
#	Private Functions
#

func _get_move_speed(delta: float) -> float:
	# Calculate the speed we're already moving at
	var previous_vel = Vector3(player.velocity.x, 0, player.velocity.z)
	var current_move_speed = previous_vel.length() / delta
	
	# If we're currently moving at a speed greater than our target,
	# then just use that speed
	if current_move_speed > move_speed:
		return current_move_speed	
	else:
		return move_speed
