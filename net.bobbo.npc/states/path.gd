class_name NPCStatePath
extends NPCState

#
#	Enums
#

## Determines the kind of target that this state should path towards.
enum TargetType {
	## Indicates that `target_node` is the thing to path towards.
	NODE,
	## Indicates that `target_position` is the thing to path towards.
	POSITION
}

#
#	Constants
#

const MESSAGE_TARGET_TYPE := "tt"
const MESSAGE_TARGET_NODE := "tn"
const MESSAGE_TARGET_POSITION := "tp"
const MESSAGE_HOW_CLOSE := "hc"

const CANCEL_REASON_PATH_FAILED := "path_failed"

#
#	Exports
#

## What should we path to? See `TargetType` for details.
@export var target_type := TargetType.POSITION

## The node to path to.
@export var target_node: Node3D = null

## The global position to path to.
@export var target_position := Vector3.ZERO

## When calculating a new path, we try to get this close to the target.
@export var how_close := 3.0

## How often should we update the nav agent's target position, in seconds?
## Setting this at or below zero will make it so this only updates the target
## position on state entry.
@export var repath_rate := 0.0

#
#	Private Variables
#

var _actively_pathing := false

#
#   State Machine Functions
#


func state_enter(message: Dictionary = {}) -> void:
	# Accept args from the message param
	target_type = message.get(MESSAGE_TARGET_TYPE, target_type)
	target_node = message.get(MESSAGE_TARGET_NODE, target_node)
	target_position = message.get(MESSAGE_TARGET_POSITION, target_position)
	how_close = message.get(MESSAGE_HOW_CLOSE, how_close)

	agent_3d.nav_agent.target_desired_distance = how_close
	agent_3d.nav_agent.target_position = _get_target_position()
	_actively_pathing = true


func state_physics_process(_delta: float) -> void:
	if not _actively_pathing:
		return

	# If we're pathing and we're now within range of the target...
	if agent_3d.nav_agent.distance_to_target() <= how_close:
		# Mark that we should no longer be pathing
		_actively_pathing = false

		# Face the target, and mark that this routine is complete
		agent_3d.look_at_point(_get_target_position())
		completed.emit()
		return

	# Path towards the target
	var next_pos = agent_3d.move_towards_nav_target()

	# Face the path
	var look_pos = next_pos
	look_pos.y = agent_3d.head_node.global_position.y
	agent_3d.look_at_point(look_pos)


#
#	Private Functions
#


func _get_target_position() -> Vector3:
	if target_type == TargetType.NODE:
		return target_node.global_position
	if target_type == TargetType.POSITION:
		return target_position

	printerr("Unhandled target type %s" % target_type)
	return Vector3.ZERO
