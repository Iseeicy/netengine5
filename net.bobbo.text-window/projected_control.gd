# This script was heavily inspired by the 3D Waypoints example
# project. See: https://github.com/godotengine/godot-demo-projects/tree/master/3d/waypoints
extends Control
class_name ProjectedControl

#
#	Exported
#

@export var behaviour: ProjectedControlBehaviour = ProjectedControlBehaviourHide.new()

#
#	Variables
#

@onready var _camera = get_viewport().get_camera_3d()
var _focus_target = null 
var _unprojected_position = Vector2.ZERO
var _is_target_behind_cam = false
var _distance_to_target: float = 0

#
#	Godot Functions
#

func _ready():
	if behaviour:
		behaviour.call_behaviour_init(self)
	
	# Set priority so this executes after camera movement
	set_process_priority(100)

func _process(delta):
	# Update the camera if it's not the current one
	if not _camera.current:
		_camera = get_viewport().get_camera_2d()
		
	if get_focus_target() != null:
		var target_transform = get_focus_target().global_transform
		_distance_to_target = _distance_to_cam(target_transform, _camera)
		_unprojected_position = _camera.unproject_position(target_transform.origin)
		_is_target_behind_cam = _is_transform_behind_cam(target_transform, _camera)
	else:
		_distance_to_target = INF
		_unprojected_position = Vector2.ZERO
		_is_target_behind_cam = false
	
	if behaviour:
		behaviour.call_behaviour_process(delta)
		
#
#	Functions
#

func set_focus_target(target_node) -> void:
	_focus_target = target_node
	
func get_camera():
	return _camera
	
func get_focus_target():
	return _focus_target
	
func get_unprojected_position():
	return _unprojected_position
	
func get_is_target_behind_cam():
	return _is_target_behind_cam
	
func get_distance_to_target():
	return _distance_to_target
	
# Get the base size of the viewport
func get_viewport_base_size():
	# `get_size_override()` will return a valid size only if the stretch mode is `2d`.
	# Otherwise, the viewport size is used directly.
	if get_viewport().content_scale_size > Vector2i(0, 0):
		return get_viewport().content_scale_size
	else:
		return get_viewport().size
	
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
		

