@tool
class_name NPCAgent3D
extends CharacterAgent3D

#
#   Exports
#

## OPTIONAL. The navigation agent to drive pathfinding for this agent.
@export var nav_agent: NavigationAgent3D = null

#
#   Public Variables
#

var sim_input: SimulatedInput:
	get:
		return input as SimulatedInput

#
#   Godot Functions
#

# TODO - setup config error if input isn't sim

#
#   Public Functions
#


## Simulates input that moves our NPC towards wherever the naviation
## agent is pointing it.
func move_towards_nav_target() -> void:
	move_in_dir_relative(
		global_position.direction_to(nav_agent.get_next_path_position())
	)


## Simulates input that moves our NPC towards a certain 3D direction,
## ignoring height.
func move_in_dir_relative(direction: Vector3) -> void:
	sim_input.simulate_axis_2d(
		BobboInputs.Player.Move.axis, Vector2(direction.x, direction.z)
	)


## Simulates input that makes our NPC look towards a certain 3D
## direction.
func look_in_dir(direction: Vector3) -> void:
	var head_direction: Vector3 = -head_node.global_transform.basis.z

	# Take our input direction, and use that to calculate the x/y mouse
	# movement that would be required to have the agent look to that
	# specific direction from their current look direction.
	var x = -_angle_around_axis(direction, head_direction, up_direction)
	var y = -_angle_around_axis(
		direction, head_direction, up_direction.cross(-head_direction)
	)

	# The mouselook player script is using degrees, so don't forget to convert!
	sim_input.simulate_axis_2d(
		BobboInputs.Player.Look.axis, Vector2(rad_to_deg(x), rad_to_deg(y))
	)


## Simulates stopping to move our NPC.
func dont_move() -> void:
	sim_input.simulate_axis_2d(BobboInputs.Player.Move.axis, Vector2.ZERO)


#
#	Private Functions
#


## Find the angle of some direction, given the context of what's considered forward.
## Return is in radians!
## Thank you to lordofduct at
## https://forum.unity.com/threads/get-rotation-around-transform-up.248924/
func _angle_around_axis(
	direction: Vector3, forward: Vector3, axis: Vector3
) -> float:
	var right_axis = axis.cross(forward)
	var forward_axis = right_axis.cross(axis)
	return atan2(direction.dot(right_axis), direction.dot(forward_axis))
