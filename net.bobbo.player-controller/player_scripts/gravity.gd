extends PlayerControllerScript

#
#	Exported
#

@export var gravity_force: float = 12
@export var max_fall_speed: float = 100

#
#	Functions
#

func player_physics_process(delta: float) -> void:
	# If we're on the floor, don't bother trying to fall
	if player.is_on_floor():
		return
		
	# If we're already falling equal to or faster than our max fall
	# speed, EXIT EARLY
	if player.velocity.y <= -max_fall_speed:
		return
		
	# Calculate the gravity force, capping out at our max fall speed
	var new_y_velocity = player.velocity.y - gravity_force * delta
	if new_y_velocity < -max_fall_speed:
		new_y_velocity = -max_fall_speed
	
	# Apply the calculated gravity
	player.velocity.y = new_y_velocity
