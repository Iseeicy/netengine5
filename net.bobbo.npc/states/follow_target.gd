class_name NPCStateFollowTarget
extends NPCState

#
#	Exports
#

## The target node to follow.
@export var target: Node3D = null

## When we are this far away from the target, we try pathing to the
## target again.
@export var max_distance: float = 5

## How often we should re-calculate the path to the target.
@export var repath_rate: float = 0.25

#
#	Private Variables
#

var _pathing := NPCPathingLogic.new()

#
#   State Machine Functions
#


func state_enter(_message: Dictionary = {}) -> void:
	_pathing.how_close = max_distance
	_pathing.repath_rate = repath_rate
	_pathing.continuous = true
	_pathing.look_while_pathing = NPCPathingLogic.PathingLookMode.TOWARDS_PATH
	_pathing.look_after_pathing = (
		NPCPathingLogic.PathCompleteLookMode.TOWARDS_TARGET
	)
	_pathing.set_target(target)
	_pathing.start_logic(self)


func state_physics_process(_delta: float) -> void:
	_pathing.process_logic()


func state_exit() -> void:
	_pathing.stop_logic()
