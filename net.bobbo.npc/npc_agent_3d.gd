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
	move_in_direction(
		global_position.direction_to(nav_agent.get_next_path_position())
	)


## Simulates input that moves our NPC towards a certain 3D direction,
## ignoring height.
func move_in_direction(direction: Vector3) -> void:
	sim_input.simulate_axis_2d(
		BobboInputs.Player.Move.axis, Vector2(direction.x, direction.z)
	)


## Simulates input that makes our NPC look towards a certain 3D
## direction.
func look_in_direction(direction: Vector3) -> void:
	var head_direction: Vector3 = -head_node.global_transform.basis.z
	var delta_rotation := Quaternion(head_direction, direction)
	var flattened_rotation := delta_rotation.get_euler(EULER_ORDER_XYZ)

	sim_input.simulate_axis_2d(
		BobboInputs.Player.Look.axis,
		Vector2(flattened_rotation.x, flattened_rotation.y)
	)


## Simulates stopping to move our NPC.
func dont_move() -> void:
	sim_input.simulate_axis_2d(BobboInputs.Player.Move.axis, Vector2.ZERO)
