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
#   Godot Functions
#


func _init() -> void:
	# Make sure we react to visibility changes
	visibility_changed.connect(_on_self_visibility_changed.bind())


func _enter_tree() -> void:
	add_to_group(GROUP_NAME)


func _exit_tree() -> void:
	remove_from_group(GROUP_NAME)


#
#   Signals
#


func _on_self_visibility_changed() -> void:
	return
