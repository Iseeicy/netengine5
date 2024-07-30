class_name NPCStateFollowTarget
extends NPCState

#
#	Exports
#

## The target node to follow.
@export var target: Node3D = null

## When calculating a new path, we try to get this close to the target.
@export var min_distance: float = 3

## When we are this far away from the target, we try pathing to the
## player again.
@export var max_distance: float = 5

#
#   State Machine Functions
#


func state_enter(_message: Dictionary = {}) -> void:
	agent_3d.nav_agent.target_desired_distance = min_distance


func state_physics_process(_delta: float) -> void:
	var further_than_max_distance: bool = (
		agent_3d.global_position.distance_to(target.global_position)
		> max_distance
	)

	# If our distance to the target is more than our desired max...
	if further_than_max_distance:
		# Try to repath to the target postion
		agent_3d.nav_agent.target_position = target.global_position

	# If our navigation isn't finished and we're not as close as we wanna be...
	if (
		not agent_3d.nav_agent.is_navigation_finished()
		and agent_3d.nav_agent.distance_to_target() > min_distance
	):
		var next_pos = agent_3d.move_towards_nav_target()

		# Face the path
		var look_pos = next_pos
		look_pos.y = agent_3d.head_node.global_position.y
		agent_3d.look_at_point(look_pos)
	else:
		# Face the target
		agent_3d.look_at_point(target.global_position)


#
#   Private Functions
#


func _distance_to_target() -> float:
	return agent_3d.global_position.distance_to(target.global_position)
