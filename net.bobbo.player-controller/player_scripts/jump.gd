extends PlayerControllerScript

#
#	Exported
#

@export var jump_impulse: float = 6
@export var support_ground_jump: bool = true
@export var support_wall_jump: bool = false

#
#	Functions
#

func player_physics_process(_delta) -> void:
	if support_ground_jump:
		player.velocity += calc_ground_jump_velocity()
	if support_wall_jump:
		player.velocity += calc_wall_jump_velocity()
	
func calc_ground_jump_velocity() -> Vector3:
	if not player.is_on_floor() or not Input.is_action_just_pressed("player_jump"):
		return Vector3.ZERO
	else:
		return Vector3(0, jump_impulse, 0)
		
func calc_wall_jump_velocity() -> Vector3:
	if not player.is_on_wall() or not Input.is_action_just_pressed("player_jump"):
		return Vector3.ZERO
	else:
		var vert_jump = Vector3(0, jump_impulse, 0)
		var wall_jump = player.get_wall_normal() * jump_impulse
		
		return 	lerp(vert_jump, wall_jump, 0.5)
		
		
