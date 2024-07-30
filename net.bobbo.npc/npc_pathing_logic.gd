class_name NPCPathingLogic
extends RefCounted

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
#   Public Variables
#

## Is this pathing complete?
var is_complete:
	get:
		return _is_complete

## Has this instance been setup?
var is_setup:
	get:
		return _is_setup

## What should we path to? See `TargetType` for details.
var target_type := TargetType.POSITION

## The node to path to.
var target_node: Node3D = null

## The global position to path to.
var target_position := Vector3.ZERO

## When calculating a new path, we try to get this close to the target.
var how_close := 3.0

## How often should we update the nav agent's target position, in seconds?
## Setting this at or below zero will make it so this only updates the target
## position on state entry.
var repath_rate := 0.0

#
#   Private Variables
#

var _state: NPCState = null
var _actively_pathing := false
var _repath_timer: Timer = null
var _is_setup := false
var _is_complete := false

#
#   Public Functions
#


func start_logic(state: NPCState) -> void:
	_state = state

	# Setup the nav agent
	_state.agent_3d.nav_agent.target_desired_distance = how_close
	_apply_nav_target()

	# Setup the repath timer
	_setup_repath_timer()
	if repath_rate > 0:
		_repath_timer.start(repath_rate)

	_actively_pathing = true
	_is_complete = false
	_is_setup = true


func process_logic() -> void:
	if not is_setup:
		return
	if not _actively_pathing:
		return

	# If we're pathing and we're now within range of the target...
	if _state.agent_3d.nav_agent.distance_to_target() <= how_close:
		# Mark that we should no longer be pathing
		_actively_pathing = false

		# Face the target, and mark that this routine is complete
		_state.agent_3d.look_at_point(_get_target_position())
		_is_complete = true
		return

	# Path towards the target
	var next_pos = _state.agent_3d.move_towards_nav_target()

	# Face the path
	var look_pos = next_pos
	look_pos.y = _state.agent_3d.head_node.global_position.y
	_state.agent_3d.look_at_point(look_pos)


func stop_logic() -> void:
	if not is_setup:
		return

	_teardown_repath_timer()
	_is_complete = false
	_state = null
	_is_setup = false


func set_target(target: Variant) -> void:
	if target is Node3D:
		target_type = TargetType.NODE
		target_node = target
	elif target is Vector3:
		target_type = TargetType.POSITION
		target_position = target
	else:
		printerr("Unhandled target type %s" % target)


#
#   Private Functions
#


func _setup_repath_timer() -> void:
	# Create the repath timer and make sure it will repeat when started
	_repath_timer = Timer.new()
	_state.add_child(_repath_timer, false, Node.INTERNAL_MODE_BACK)
	_repath_timer.one_shot = false
	_repath_timer.timeout.connect(_on_repath_timer_timeout.bind())


func _teardown_repath_timer() -> void:
	_repath_timer.stop()
	_repath_timer.queue_free()
	_repath_timer = null


func _get_target_position() -> Vector3:
	if target_type == TargetType.NODE:
		return target_node.global_position
	if target_type == TargetType.POSITION:
		return target_position

	printerr("Unhandled target type %s" % target_type)
	return Vector3.ZERO


func _apply_nav_target() -> void:
	_state.agent_3d.nav_agent.target_position = _get_target_position()


func _on_repath_timer_timeout() -> void:
	_apply_nav_target()
