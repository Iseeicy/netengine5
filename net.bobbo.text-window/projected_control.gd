# This script was heavily inspired by the 3D Waypoints example
# project. See: https://github.com/godotengine/godot-demo-projects/tree/master/3d/waypoints
extends Control
class_name ProjectedControl

#
#	Exported
#

@export var is_sticky: bool = false

# If this is sticky, this is the node to rotate when the control
# is off-screen
@export var sticky_rotate: Control = null

# If this is sticky, this is the node to make invisible when the
# control is off-screen
@export var sticky_visible: Control = null

#
#	Variables
#

const MARGIN = 8	# Used when offsetting off-screen control
@onready var _camera = get_viewport().get_camera_3d()
var _focus_target = null 
var _distance_to_target: float = 0

#
#	Godot Functions
#

func _process(delta):
	# Update the camera if it's not the current one
	if not _camera.current:
		_camera = get_viewport().get_camera_2d()
		
	# Behave differently depending on if we have a target or not
	if get_focus_target() != null:
		_process_while_targeting(delta)
	else:
		_process_while_no_target(delta)
		
func _process_while_targeting(delta: float) -> void:
	var target_transform = get_focus_target().global_transform
	
	_distance_to_target = _distance_to_cam(target_transform, _camera)
	var unprojected_position = _camera.unproject_position(target_transform.origin)
	
	# For non-sticky controls, we have all we need. If the target
	# is off screen we'll just hide this node.
	if not is_sticky:
		position = unprojected_position
		visible = not _is_transform_behind_cam(target_transform, _camera)
	# For sticky controls, we have to correct the unprojected
	# position in order to address the edges of the screen
	else:
		position = _correct_unprojected_position(
			target_transform, 
			_camera, 
			unprojected_position
		)
		_handle_sticky_children(sticky_rotate, sticky_visible)
		

	
	# Fade the waypoint when the camera gets close.
	# modulate.a = clamp(remap(distance, 0, 2, 0, 1), 0, 1 )
	
	
func _process_while_no_target(delta: float) -> void:
	return
	

#
#	Functions
#

func set_focus_target(target_node) -> void:
	_focus_target = target_node
	
func get_focus_target():
	return _focus_target
	
#
#	Private Functions
#

# Is the given transform behind the given camera?
func _is_transform_behind_cam(target_transform, cam) -> bool:
	# We would use "camera.is_position_behind(parent_position)", except
	# that it also accounts for the near clip plane, which we don't want.
	return cam.global_transform.basis.z.dot(target_transform.origin - cam.global_transform.origin) > 0
	
# Find the distance between the given transform and the given camera
func _distance_to_cam(target_transform, cam) -> float:
	return cam.global_transform.origin.distance_to(target_transform.origin)
	
# Get the base size of the viewport
func _get_viewport_base_size():
	# `get_size_override()` will return a valid size only if the stretch mode is `2d`.
	# Otherwise, the viewport size is used directly.
	if get_viewport().content_scale_size > Vector2i(0, 0):
		return get_viewport().content_scale_size
	else:
		return get_viewport().size
		
func _correct_unprojected_position(target_transform, cam, unprojected_position):
	var is_behind = _is_transform_behind_cam(target_transform, cam)
	var viewport_base_size = _get_viewport_base_size()
	# We need to handle the axes differently.
		
	# For the screen's X axis, the projected position is useful to us,
	# but we need to force it to the side if it's also behind.
	if is_behind:
		if unprojected_position.x < viewport_base_size.x / 2:
			unprojected_position.x = viewport_base_size.x - MARGIN
		else:
			unprojected_position.x = MARGIN
			
	# For the screen's Y axis, the projected position is NOT useful to us
	# because we don't want to indicate to the user that they need to look
	# up or down to see something behind them. Instead, here we approximate
	# the correct position using difference of the X axis Euler angles
	# (up/down rotation) and the ratio of that with the camera's FOV.
	# This will be slightly off from the theoretical "ideal" position.
	if is_behind or unprojected_position.x < MARGIN or \
			unprojected_position.x > viewport_base_size.x - MARGIN:
		var look = cam.global_transform.looking_at(target_transform.origin, Vector3.UP)
		var diff = _calc_angle_diff(look.basis.get_euler().x, cam.global_transform.basis.get_euler().x)
		unprojected_position.y = viewport_base_size.y * (0.5 + (diff / deg_to_rad(cam.fov)))

	return Vector2(
			clamp(unprojected_position.x, MARGIN, viewport_base_size.x - MARGIN),
			clamp(unprojected_position.y, MARGIN, viewport_base_size.y - MARGIN)
	)

func _calc_angle_diff(from, to):
	var diff = fmod(to - from, TAU)
	return fmod(2.0 * diff, TAU) - diff
	
func _handle_sticky_children(to_rotate: Control, to_visible: Control):
	var viewport_base_size = _get_viewport_base_size()
	var sticky_rotation: float = 0
	var sticky_is_visible: bool = true
	var overflow: float = 0
	
	if position.x <= MARGIN:
		# Left overflow.
		overflow = -TAU / 8.0
		sticky_is_visible = false
		sticky_rotation = TAU / 4.0
	elif position.x >= viewport_base_size.x - MARGIN:
		# Right overflow.
		overflow = TAU / 8.0
		sticky_is_visible = false
		sticky_rotation = TAU * 3.0 / 4.0

	if position.y <= MARGIN:
		# Top overflow.
		sticky_is_visible = false
		sticky_rotation = TAU / 2.0 + overflow
	elif position.y >= viewport_base_size.y - MARGIN:
		# Bottom overflow.
		sticky_is_visible = false
		sticky_rotation = -overflow
		
	if to_rotate:
		to_rotate.rotation = sticky_rotation
	if to_visible:
		to_visible.visible = sticky_is_visible
