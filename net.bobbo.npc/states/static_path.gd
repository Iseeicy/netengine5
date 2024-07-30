class_name NPCStateStaticPath
extends NPCState

#
#	Constants
#

const CANCEL_REASON_PATH_FAILED := "path_failed"

#
#	Exports
#

## The global position to path to.
@export var target_position: Vector3 = Vector3.ZERO

## When calculating a new path, we try to get this close to the target.
@export var how_close: float = 3

#
#	Private Variables
#

var _actively_pathing := false

#
#   State Machine Functions
#


func state_enter(message: Dictionary = {}) -> void:
	# Accept args from the message param
	target_position = message.get("target_position", target_position)
	how_close = message.get("how_close", how_close)

	agent_3d.nav_agent.target_desired_distance = how_close
	agent_3d.nav_agent.target_position = target_position
	_actively_pathing = true


func state_physics_process(_delta: float) -> void:
	if not _actively_pathing:
		return

	# If we're pathing and we're now within range of the target...
	if agent_3d.nav_agent.distance_to_target() <= how_close:
		# Mark that we should no longer be pathing
		_actively_pathing = false

		# Face the target, and mark that this routine is complete
		agent_3d.look_at_point(target_position)
		completed.emit()
		return

	# Path towards the target
	var next_pos = agent_3d.move_towards_nav_target()

	# Face the path
	var look_pos = next_pos
	look_pos.y = agent_3d.head_node.global_position.y
	agent_3d.look_at_point(look_pos)
