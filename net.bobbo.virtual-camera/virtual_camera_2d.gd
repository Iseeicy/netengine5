class_name VirtualCamera2D
extends Node2D

#
#   Constants
#

## The name of the group that ALL `VirtualCamera2D`s are stored in.
const GROUP_NAME: String = "vcams_2d_all"

## The name of the group that all VISIBLE `VirtualCamera2D`s are stored
## in. VCams will be added and removed to this group upon change in
## the `visible` property.
const VISIBLE_GROUP_NAME: String = "vcams_2d_visible"

#
#	Static Functions
#


## Get all of the 2D VCams that exist in the given scene.
## Args:
##	`scene_tree`: OPTIONAL. The SceneTree to get the 2D VCams from.
## Returns:
##	`Array[VirtualCamera2D]` a list of 2D VCams that exist in the given
##		scene.
static func get_all(scene_tree: SceneTree) -> Array[VirtualCamera2D]:
	# Cast the generic array from the scene tree into something typed.
	var found_vcams: Array[VirtualCamera2D] = []
	found_vcams.assign(scene_tree.get_nodes_in_group(GROUP_NAME))
	return found_vcams


## Get all of the *VISIBLE* 2D VCams that exist in the given scene.
## These are VCams that have their 2D `visible` property set to true.
## Args:
##	`scene_tree`: OPTIONAL. The SceneTree to get the 2D VCams from.
## Returns:
##	`Array[VirtualCamera2D]` a list of visible 2D VCams that exist in
##		the given scene.
static func get_visible(scene_tree: SceneTree) -> Array[VirtualCamera2D]:
	# Cast the generic array from the scene tree into something typed.
	var found_vcams: Array[VirtualCamera2D] = []
	found_vcams.assign(scene_tree.get_nodes_in_group(VISIBLE_GROUP_NAME))
	return found_vcams


#
#   Godot Functions
#


func _init() -> void:
	# Make sure we react to visibility changes
	visibility_changed.connect(_on_self_visibility_changed.bind())

	# ...and call the callback right away, so we start with a good state
	_on_self_visibility_changed()


func _enter_tree() -> void:
	add_to_group(GROUP_NAME)


func _exit_tree() -> void:
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
