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
func move_towards_nav_target() -> Vector3:
	var next_position := nav_agent.get_next_path_position()
	move_in_dir_global(global_position.direction_to(next_position))
	return next_position


## Simulates input that moves our NPC towards a certain 3D direction,
## ignoring height, RELATIVE to where the agent's head is facing.
## For example: If the given direction is `Vector3.FORWARD`, this will
## always move the agent towards the direction that they're facing.
func move_in_dir_relative(direction: Vector3) -> void:
	sim_input.simulate_axis_2d(
		BobboInputs.Player.Move.axis, Vector2(direction.x, direction.z)
	)


## Simulates input that moves our NPC towards a certain 3D direction,
## ignoring height.
func move_in_dir_global(direction: Vector3) -> void:
	# Thanks to https://www.reddit.com/r/godot/comments/tw78dr/comment/jib4fwg/
	move_in_dir_relative(
		head_node.global_transform.basis.inverse() * direction
	)


## Simulates input that makes our NPC look towards a certain 3D
## direction.
func look_in_dir(direction: Vector3) -> void:
	var head_direction: Vector3 = -head_node.global_transform.basis.z
	var dir_euler = Basis.looking_at(direction).get_euler()
	var head_euler = Basis.looking_at(head_direction).get_euler()

	# Take our input direction, and use that to calculate the x/y mouse
	# movement that would be required to have the agent look to that
	# specific direction from their current look direction.
	var x = -_angle_around_axis(direction, head_direction, up_direction)
	var y = -_angle_around_axis(
		direction, head_direction, up_direction.cross(-head_direction)
	)

	print(
		(
			"DEBUG\nlookdir %s\nheaddir %s\nx %s\ny %s\n"
			% [
				[
					direction,
					rad_to_deg(dir_euler.x),
					rad_to_deg(dir_euler.y),
					rad_to_deg(dir_euler.z)
				],
				[
					head_direction,
					rad_to_deg(head_euler.x),
					rad_to_deg(head_euler.y),
					rad_to_deg(head_euler.z)
				],
				rad_to_deg(x),
				rad_to_deg(y)
			]
		)
	)

	# The mouselook player script is using degrees, so don't forget to convert!
	sim_input.simulate_axis_2d(
		BobboInputs.Player.Look.axis, Vector2(rad_to_deg(x), rad_to_deg(y))
	)


## Simlates input that makes our NPC look towards a certain point in 3D
## space.
func look_at_point(point: Vector3) -> void:
	look_in_dir(head_node.global_position.direction_to(point))


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
