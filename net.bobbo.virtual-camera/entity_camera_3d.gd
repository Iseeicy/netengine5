class_name EntityCamera3D
extends Node3D

#
#	Exports
#

@export var default_transition: CameraTransition = null

#
#	Private Variables
#

var _current_transitioner: CameraTransitioner3D = null
var _target_camera: VirtualCamera3D = null

#
#   Godot Functions
#


func _ready():
	if default_transition == null:
		default_transition = CameraTransition.new()


func _process(_delta):
	var current_target_camera = _find_target_camera()

	# If we have a new target camera that is NOT the one we previously
	# knew about...
	if current_target_camera != _target_camera:
		# ...update our known target camera
		_target_camera = current_target_camera

		# If we were already transitioning, stop the transition
		if _current_transitioner:
			_current_transitioner.queue_free()
			_current_transitioner = null

		# If the new target camera is real, start a transition
		if current_target_camera != null:
			# Create the transitioner
			var new_transitioner = default_transition.create_transitioner_3d(
				self, current_target_camera
			)
			_current_transitioner = new_transitioner

			# Setup a callback to remove the transitioner val upon finishing
			# transition
			var on_complete_func = func():
				if _current_transitioner == new_transitioner:
					_current_transitioner = null
			new_transitioner.transition_complete.connect(on_complete_func.bind())
	
	# If we have a target camera and we're not still transitioning to it...
	elif _target_camera != null and _current_transitioner == null:
		# ...then snap our position!
		global_position = _target_camera.global_position
		global_rotation = _target_camera.global_rotation



#
#   Private Functions
#


## Find the VCam with the highest priority in the tree.
func _find_target_camera() -> VirtualCamera3D:
	# Find all visible cameras. If there are none, EXIT EARLY.
	var visible_cameras := VirtualCamera3D.get_visible(get_tree())
	if visible_cameras.size() == 0:
		return null

	# Find the camera with the highest priority.
	# TODO - what do we do when two cameras have the same priority?
	var candidate_camera: VirtualCamera3D = visible_cameras[0]
	for cam in visible_cameras:
		if (
			cam.get_priority(get_viewport())
			> candidate_camera.get_priority(get_viewport())
		):
			candidate_camera = cam

	return candidate_camera
