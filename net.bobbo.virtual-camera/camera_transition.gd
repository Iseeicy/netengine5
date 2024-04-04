class_name CameraTransition
extends Resource

#
#   Exports
#

## How long the transition will take, in seconds.
@export var duration: float = 2

## The way in which the camera is transitioned. See https://easings.net/
## for examples.
@export var transition_type := Tween.TransitionType.TRANS_SINE

## The type of easing to use when transitioning
@export var ease_type := Tween.EaseType.EASE_IN_OUT

#
#   Public Functions
#


func create_transitioner_3d(
	entity_camera: EntityCamera3D, virtual_camera: VirtualCamera3D
) -> CameraTransitioner3D:
	## Create the transitioner with our info
	var transitioner := CameraTransitioner3D.new(
		self, entity_camera, virtual_camera
	)

	## Place the transitioner as a hidden internal node under the entity
	## camera.
	entity_camera.add_child(transitioner, false, Node.INTERNAL_MODE_BACK)

	return transitioner
