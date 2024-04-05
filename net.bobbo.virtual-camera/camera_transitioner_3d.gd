## A node that transitions an `EntityCamera3D` from some starting point
## to a `VirtualCamera3D`, given a `CameraTransition` resource to use
## as config. Not meant to be created manually.
class_name CameraTransitioner3D
extends Node

## Emitted when this camera transition has completed, just before this
## node is queued to be freed.
signal transition_complete

#
#	Public Variables
#

## Information about the transition to perform
var transition: CameraTransition

## The camera to transition
var target_camera: EntityCamera3D

## The virtual camera to end up at when completing the transition.
var destination_vcam: VirtualCamera3D

#
#	Private Variables
#

## The global position of the camera when it started being transitioned.
var _starting_position: Vector3

## The global rotation of the camera when it started being transitioned.
var _starting_rotation: Vector3

## How much time has passed since `_ready()`
var _time_elapsed: float = 0

#
#   Godot Functions
#


func _init(
	transition: CameraTransition,
	target_camera: EntityCamera3D,
	destination_vcam: VirtualCamera3D
):
	self.transition = transition
	self.target_camera = target_camera
	self.destination_vcam = destination_vcam
	_starting_position = target_camera.global_position
	_starting_rotation = target_camera.global_rotation


func _process(delta: float):
	# Move the camera
	target_camera.global_position = _calculate_tweened_position()
	target_camera.global_rotation = _calculate_tweened_rotation()

	# If the transition is done, remove this node and tell anyone who
	# wants to know
	if _time_elapsed >= transition.duration:
		transition_complete.emit()
		queue_free()
		return

	# Keep track of time
	_time_elapsed += delta


#
#   Private Functions
#


func _calculate_tweened_position() -> Vector3:
	return Tween.interpolate_value(
		_starting_position,
		destination_vcam.global_position - _starting_position,
		_time_elapsed,
		transition.duration,
		transition.transition_type,
		transition.ease_type
	)


func _calculate_tweened_rotation() -> Vector3:
	return Tween.interpolate_value(
		_starting_rotation,
		destination_vcam.global_rotation - _starting_rotation,
		_time_elapsed,
		transition.duration,
		transition.transition_type,
		transition.ease_type
	)
