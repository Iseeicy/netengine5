## Allows an agent to jump.
extends CharacterAgentScript

#
#	Exported
#

@export var jump_impulse: float = 6
@export var support_ground_jump: bool = true
@export var support_wall_jump: bool = false

#
#	Agent Functions
#


func character_agent_physics_process(_delta) -> void:
	if support_ground_jump:
		agent_3d.velocity += calc_ground_jump_velocity()
	if support_wall_jump:
		agent_3d.velocity += calc_wall_jump_velocity()


#
#	Private Functions
#


func calc_ground_jump_velocity() -> Vector3:
	var should_jump = agent_3d.input.is_action_just_pressed(
		BobboInputs.Player.JUMP
	)
	if not agent_3d.is_on_floor() or not should_jump:
		return Vector3.ZERO

	return Vector3(0, jump_impulse, 0)


func calc_wall_jump_velocity() -> Vector3:
	var should_jump = agent_3d.input.is_action_just_pressed(
		BobboInputs.Player.JUMP
	)
	if not agent_3d.is_on_wall() or not should_jump:
		return Vector3.ZERO

	var vert_jump = Vector3(0, jump_impulse, 0)
	var wall_jump = agent_3d.get_wall_normal() * jump_impulse

	return lerp(vert_jump, wall_jump, 0.5)
