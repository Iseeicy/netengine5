class_name EntityCamera2D
extends Node2D

#
#   Godot Functions
#


func _process(_delta):
	var target_camera = _find_target_camera()
	if target_camera == null:
		return

	# Snap to the target camera
	global_position = target_camera.global_position
	global_rotation = target_camera.global_rotation


#
#   Private Functions
#


## Find the VCam with the highest priority in the tree.
func _find_target_camera() -> VirtualCamera2D:
	# Find all visible cameras. If there are none, EXIT EARLY.
	var visible_cameras := VirtualCamera2D.get_visible(get_tree())
	if visible_cameras.size() == 0:
		return null

	# Find the camera with the highest priority.
	# TODO - what do we do when two cameras have the same priority?
	var candidate_camera: VirtualCamera2D = visible_cameras[0]
	for cam in visible_cameras:
		if (
			cam.get_priority(get_viewport())
			> candidate_camera.get_priority(get_viewport())
		):
			candidate_camera = cam

	return candidate_camera
