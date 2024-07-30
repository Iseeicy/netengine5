class_name NPCStateGoToPosition
extends NPCState

#
#	Exports
#

## Invoked when the NPC has reached its target position.
signal path_completed

## The global position to path to.
@export var target_position: Vector3 = Vector3.ZERO

## When calculating a new path, we try to get this close to the target.
@export var how_close: float = 3

#
#	Private Variables
#

var _runtime_callbacks: Array[Callable] = []
var _actively_pathing := false

#
#   State Machine Functions
#


func state_enter(message: Dictionary = {}) -> void:
	# Accept args from the message param
	target_position = message.get("target_position", target_position)
	how_close = message.get("how_close", how_close)
	if message.has("on_complete"):
		var on_complete_func := message.get("on_complete") as Callable
		_runtime_callbacks.append(on_complete_func)
		path_completed.connect(on_complete_func)

	agent_3d.nav_agent.target_desired_distance = how_close
	agent_3d.nav_agent.target_position = target_position
	_actively_pathing = true


func state_exit() -> void:
	# Disconnect any callbacks created at runtime
	for callback in _runtime_callbacks:
		path_completed.disconnect(callback)


func state_physics_process(_delta: float) -> void:
	# If our navigation isn't finished and we're not as close as we wanna be...
	if (
		not agent_3d.nav_agent.is_navigation_finished()
		and agent_3d.nav_agent.distance_to_target() > how_close
	):
		var next_pos = agent_3d.move_towards_nav_target()

		# Face the path
		var look_pos = next_pos
		look_pos.y = agent_3d.head_node.global_position.y
		agent_3d.look_at_point(look_pos)
	else:
		# Face the target
		agent_3d.look_at_point(target_position)

	if agent_3d.nav_agent.is_navigation_finished() and _actively_pathing:
		_actively_pathing = false
		path_completed.emit()
