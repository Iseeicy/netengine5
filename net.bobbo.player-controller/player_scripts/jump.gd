extends PlayerControllerScript

#
#	Constant
#

const JUMP_ACTION: String = "player_jump"

#
#	Exported
#

@export var jump_impulse: float = 6
@export var support_ground_jump: bool = true
@export var support_wall_jump: bool = false

#
#	Private Variables
#

## Is the entity trying to jump right now?
var _should_jump: bool = false

#
#	Agent Functions
#


func character_agent_process(_delta: float) -> void:
	# Cache our input in process so we can use it in physics_process
	if not _should_jump and agent_3d.input.is_action_just_pressed(JUMP_ACTION):
		_should_jump = true


func character_agent_physics_process(_delta) -> void:
	if support_ground_jump:
		agent_3d.velocity += calc_ground_jump_velocity()
	if support_wall_jump:
		agent_3d.velocity += calc_wall_jump_velocity()

	# Make sure to reset the jump flag
	if _should_jump:
		_should_jump = false


#
#	Private Functions
#


func calc_ground_jump_velocity() -> Vector3:
	if not agent_3d.is_on_floor() or not _should_jump:
		return Vector3.ZERO

	return Vector3(0, jump_impulse, 0)


func calc_wall_jump_velocity() -> Vector3:
	if not agent_3d.is_on_wall() or not _should_jump:
		return Vector3.ZERO

	var vert_jump = Vector3(0, jump_impulse, 0)
	var wall_jump = agent_3d.get_wall_normal() * jump_impulse

	return lerp(vert_jump, wall_jump, 0.5)
