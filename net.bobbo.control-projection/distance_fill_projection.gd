extends ControlProjection
class_name DistanceFillProjection

enum State {
	FillScreen,
	InWorld,
	TooFar
}

#
#	Exported
#

@export_group("Filled Layout")
@export var filled_anchor_pos: Vector2 = Vector2(0.5, 0.5)
@export var filled_anchor_offset: Vector2 = Vector2(0, 0)

@export_group("Distance")
@export var closeness_threshold: float = 4
@export var max_distance: float = 15

@export_group("Time")
@export var fill_screen_speed: float = 4
@export var fill_screen_curve: float = 0.2
@export var enter_world_speed: float = 2
@export var enter_world_curve: float = 0.2

#
#	Variables
#

var state = State.TooFar
var _is_lerping: bool = false
var _ease_type: float = 1
var _lerp_start_pos: Vector2 = Vector2.ZERO
var _lerp_end_pos: Vector2 = Vector2.ZERO
var _lerp_start_scale: Vector2 = Vector2.ONE
var _lerp_end_scale: Vector2 = Vector2.ONE
var _lerp_progress: float = 0

#
#	Functions
#

func _process(delta: float) -> void:
	super(delta)

	# Calculate our state depending on distance, and handle any scenario
	# where we need to enter a new state
	var new_state = _calc_state()
	if new_state != state:
		_set_state(new_state)

	# Run the mini state machine
	match state:
		State.FillScreen:
			_state_fill_screen_process(delta)
		State.InWorld:
			_state_in_world_process(delta)
		State.TooFar:
			_state_too_far_process(delta)

#
#	Private Functions
#

func _state_fill_screen_enter(prev_state: State) -> void:
	var target_position = _state_fill_screen_calc_target_pos()
	var target_scale = _state_fill_screen_calc_target_scale()
	
	if prev_state == State.TooFar:
		position = target_position
		scale = target_scale
	
	_start_tween(
		fill_screen_curve,
		position,
		target_position,
		scale,
		target_scale
	)

func _state_fill_screen_process(delta: float) -> void:
	_lerp_end_pos = _state_fill_screen_calc_target_pos()
	_update_tween(delta * fill_screen_speed)
	visible = true
	
func _state_fill_screen_calc_target_pos():
	var viewport_size = get_viewport_base_size()
	var scaled_base_pos = Vector2(
		remap(filled_anchor_pos.x, 0.0, 1.0, 0.0, viewport_size.x),
		remap(filled_anchor_pos.y, 0.0, 1.0, 0.0, viewport_size.y)
	)
	
	return scaled_base_pos + filled_anchor_offset
	
func _state_fill_screen_calc_target_scale():
	return Vector2.ONE



func _state_in_world_enter(prev_state: State) -> void:
	var target_position = _state_in_world_calc_target_pos()
	var target_scale = _state_in_world_calc_target_scale()
	
	if prev_state == State.TooFar:
		position = target_position
		scale = target_scale
	
	_start_tween(
		enter_world_curve,
		position,
		target_position,
		scale,
		target_scale
	)

func _state_in_world_process(delta: float) -> void:
	_lerp_end_pos = _state_in_world_calc_target_pos()
	_lerp_end_scale = _state_in_world_calc_target_scale()
	_update_tween(delta * enter_world_speed)
	
	visible = not get_is_target_behind_cam()

func _state_in_world_calc_target_pos():
	return get_unprojected_position()
	
func _state_in_world_calc_target_scale():
	return Vector2.ONE / clamp(get_distance_to_target(), 1, INF)



func _state_too_far_enter(prev_state: State) -> void:
	return

func _state_too_far_process(delta: float) -> void:
	visible = false
	position = get_unprojected_position()
	scale = Vector2.ONE



func _calc_state() -> State:
	var distance = get_distance_to_target()
	# If we're further than the max distance, don't display anything
	if distance > max_distance:
		if is_focusing():
			return State.TooFar
		else:
			return State.FillScreen
	# If we're under the closeness threshold, then fill the screen
	elif distance <= closeness_threshold:
		return State.FillScreen
	# If we're between thresholds, display normally
	else:
		return State.InWorld
		
func _set_state(new_state: State):
	var prev_state = state
	state = new_state
	
	match state:
		State.FillScreen:
			_state_fill_screen_enter(prev_state)
		State.InWorld:
			_state_in_world_enter(prev_state)
		State.TooFar:
			_state_too_far_enter(prev_state)
			
func _start_tween(ease_curve: float, start_pos, end_pos, start_scale, end_scale):
	_is_lerping = true
	_ease_type = ease_curve
	_lerp_progress = 0
	_lerp_start_pos = start_pos
	_lerp_end_pos = end_pos
	_lerp_start_scale = start_scale
	_lerp_end_scale = end_scale
	
func _update_tween(delta: float):
	if _lerp_progress >= 1:
		_is_lerping = false
		_lerp_progress = 1
		
	if _is_lerping:
		_lerp_progress += delta
	
	var clamped_progress = ease(clamp(_lerp_progress, 0, 1), _ease_type)
	position = lerp(
		_lerp_start_pos, 
		_lerp_end_pos, 
		clamped_progress
	)
	scale = lerp(
		_lerp_start_scale, 
		_lerp_end_scale, 
		clamped_progress
	)
