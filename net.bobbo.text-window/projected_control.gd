# This script was heavily inspired by the 3D Waypoints example
# project. See: https://github.com/godotengine/godot-demo-projects/tree/master/3d/waypoints
extends Control
class_name ProjectedControl

#
#	Exported
#

@export var is_sticky: bool = false

#
#	Variables
#

@onready var _camera = get_viewport().get_camera_3d()
var _focus_target = null 

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
	
	var is_behind = _is_transform_behind_cam(target_transform, _camera)
	var distance = _distance_to_cam(target_transform, _camera)
	var unprojected_position = _camera.unproject_position(target_transform.origin)
	var viewport_base_size = _get_viewport_base_size()
	
	# For non-sticky controls, we have all we need. If the target
	# is off screen we'll just hide this node.
	if not is_sticky:
		position = unprojected_position
		visible = not is_behind
		return

	
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
