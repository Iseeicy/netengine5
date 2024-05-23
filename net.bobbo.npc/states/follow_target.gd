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

@export_group("Catchup")
## If we are struggling to catch up to the target (it's moving faster
## than us), then this is how long we'll wait until we start trying to
## run.
@export var time_until_try_catchup: float = 2

#
#	Priate Variables
#

var _move_axis := InputAxis2d.new(
	InputAxis1d.new("player_move_left", "player_move_right"),
	InputAxis1d.new("player_move_forward", "player_move_back")
)

var _look_axis: InputAxis2d = InputAxis2d.new(
	InputAxis1d.new("player_look_left", "player_look_right"),
	InputAxis1d.new("player_look_down", "player_look_up")
)

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
	# ... try to repath to the target postion
	if further_than_max_distance:
		agent_3d.nav_agent.target_position = target.global_position

	# If our navigation isn't finished and we're not as close as we wanna be...
	if (
		not agent_3d.nav_agent.is_navigation_finished()
		and agent_3d.nav_agent.distance_to_target() > min_distance
	):
		agent_3d.move_towards_nav_target()
	else:
		agent_3d.dont_move()

	agent_3d.look_in_direction(
		agent_3d.head_node.global_position.direction_to(target.global_position)
	)


#
#   Private Functions
#


func _distance_to_target() -> float:
	return agent_3d.global_position.distance_to(target.global_position)
