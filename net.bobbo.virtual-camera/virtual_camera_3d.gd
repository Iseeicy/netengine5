class_name VirtualCamera3D
extends Node3D

#
#   Constants
#

## The name of the group that ALL `VirtualCamera3D`s are stored in.
const GROUP_NAME: String = "vcams_3d_all"

## The name of the group that all VISIBLE `VirtualCamera3D`s are stored
## in. VCams will be added and removed to this group upon change in
## the `visible` property.
const VISIBLE_GROUP_NAME: String = "vcams_3d_visible"

#
#	Static Functions
#


## Get all of the 3D VCams that exist in the given scene.
## Args:
##	`scene_tree`: OPTIONAL. The SceneTree to get the 3D VCams from.
## Returns:
##	`Array[VirtualCamera3D]` a list of 3D VCams that exist in the given
##		scene.
static func get_all(scene_tree: SceneTree) -> Array[VirtualCamera3D]:
	# Cast the generic array from the scene tree into something typed.
	var found_vcams: Array[VirtualCamera3D] = []
	found_vcams.assign(scene_tree.get_nodes_in_group(GROUP_NAME))
	return found_vcams


## Get all of the *VISIBLE* 3D VCams that exist in the given scene.
## These are VCams that have their 3D `visible` property set to true.
## Args:
##	`scene_tree`: OPTIONAL. The SceneTree to get the 3D VCams from.
## Returns:
##	`Array[VirtualCamera3D]` a list of visible 3D VCams that exist in
##		the given scene.
static func get_visible(scene_tree: SceneTree) -> Array[VirtualCamera3D]:
	# Cast the generic array from the scene tree into something typed.
	var found_vcams: Array[VirtualCamera3D] = []
	found_vcams.assign(scene_tree.get_nodes_in_group(VISIBLE_GROUP_NAME))
	return found_vcams


#
#   Godot Functions
#


func _init() -> void:
	# Make sure we react to visibility changes
	visibility_changed.connect(_on_self_visibility_changed.bind())


func _enter_tree() -> void:
	add_to_group(GROUP_NAME)

	# Manually trigger a vis change so that we add ourself to the tree's
	# visible group for this vcam type.
	_on_self_visibility_changed()


func _exit_tree() -> void:
	# Remove us from the visible group if this vcam is currently in it
	if visible:
		remove_from_group(VISIBLE_GROUP_NAME)

	remove_from_group(GROUP_NAME)


#
#   Signals
#


## Whenever this node's visibility changes, handle adding it or removing
## it to / from the visible group for this kind of VCam.
func _on_self_visibility_changed() -> void:
	if visible:
		add_to_group(VISIBLE_GROUP_NAME)
	else:
		remove_from_group(VISIBLE_GROUP_NAME)
