## A base class meant to handle Control Nodes that should be anchored onto
## objects in 3D or 2D space. This allows for UIs such as waypoints, name plates,
## floating dialog boxes, quest markers, etc.
## This node is not meant to be used directly.
# This script was heavily inspired by the 3D Waypoints example
# project. See: https://github.com/godotengine/godot-demo-projects/tree/master/3d/waypoints
extends Control
class_name ControlProjection

#
#	Variables
#

## The camera to use when projecting
@onready var _camera = get_viewport().get_camera_3d()

## Is this control currently anchored at the `_focus_position`?
var _is_focusing = false

## Where to project the control to, when `_is_focusing`.
var _focus_position = Vector3.ZERO 

## This control's position after being unprojected.
var _unprojected_position = Vector2.ZERO

## Is the focus target currently behind the camera viewport?
var _is_target_behind_cam = false

## The distance between the camera and the focus target
var _distance_to_target: float = 0

#
#	Godot Functions
#

func _get_configuration_warnings():
	return ["This does not do anything on it's own! Please use a node that inherits this class."]

func _ready():
	# Set priority so this executes after camera movement
	set_process_priority(100)

func _process(delta):
	# Update the camera if it's not the current one
	if not _camera or not _camera.current:
		_camera = get_viewport().get_camera_2d()
		
	if is_focusing():
		_distance_to_target = _distance_to_cam(_focus_position, _camera)
		_unprojected_position = _camera.unproject_position(_focus_position)
		_is_target_behind_cam = _is_transform_behind_cam(_focus_position, _camera)
	else:
		_distance_to_target = INF
		_unprojected_position = Vector2.ZERO
		_is_target_behind_cam = false
	
#
#	Functions
#

## Make this control anchor itself in space over the given position.
## This automatically marks the control as focusing.
func set_focus_position(target_position) -> void:
	_focus_position = target_position
	_is_focusing = true
	
## Make this control STOP focusing.
func reset_focus() -> void:
	_is_focusing = false
	
## Returns the camera that is being used to project.
func get_camera():
	return _camera
	
## Is this control currently focusing over a specific position?
func is_focusing() -> bool:
	return _is_focusing
	
## Returns the position that this control is currently anchored on, in global space
func get_focus_position():
	return _focus_position
	
## Get the position of this control after being unprojected.
func get_unprojected_position():
	return _unprojected_position
	
## Is the focus position currently behind the camera being used?
func get_is_target_behind_cam():
	return _is_target_behind_cam
	
## Returns the distance between the camera and the focus position
func get_distance_to_target():
	return _distance_to_target
	
## Returns the base-size of the viewport (?)
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
func _is_transform_behind_cam(pos, cam) -> bool:
	# We would use "camera.is_position_behind(parent_position)", except
	# that it also accounts for the near clip plane, which we don't want.
	return cam.global_transform.basis.z.dot(pos - cam.global_transform.origin) > 0
	
# Find the distance between the given transform and the given camera
func _distance_to_cam(pos, cam) -> float:
	return cam.global_transform.origin.distance_to(pos)
		

