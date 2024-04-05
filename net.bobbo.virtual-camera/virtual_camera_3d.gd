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
#	Exports
#

## The main priority of this VCam, compared to others of the same type.
## If there's no priority specified for a given viewport in
## `_specific_priorities`, then this value is used. A higher value will
## cause this VCam to overtake VCams of a lower priority value.
@export var main_priority: int = 0

#
#	Private Variables
#

## Dicitonary[RID, int]
## The specific priority of this camera, in a given viewport by it's
## resource ID.
var _specific_priorities: Dictionary = {}

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
#	Public Functions
#


## Get the priority of this VCam, relative to the viewport.
## See `get_priority_by_rid` for details.
func get_priority(viewport: Viewport) -> int:
	return get_priority_by_rid(
		viewport.get_viewport_rid() if viewport else null
	)


## Get the priority of this VCam, relative to a viewport. See
## `set_priority_by_rid` for details.
func set_priority(viewport: Viewport, priority: int) -> void:
	return set_priority_by_rid(
		viewport.get_viewport_rid() if viewport else null, priority
	)


## Does this VCam have a specific priority set for the given viewport,
## using it's RID as reference? See `has_priority_by_rid` for details.
func has_priority(viewport: Viewport) -> bool:
	return has_priority_by_rid(
		viewport.get_viewport_rid() if viewport else null
	)


## Remove the specific priority that this VCam has for a given viewport
## using the RID of the viewport as reference. See
## `remove_priority_by_rid` for details.
func remove_priority(viewport: Viewport) -> bool:
	return remove_priority_by_rid(
		viewport.get_viewport_rid() if viewport else null
	)


## Get the priority of this VCam, relative to the viewport using the
## RID of the viewport as reference.
## Args:
##	`viewport_rid`: The resource ID of the Viewport that we want to use
##		as reference when getting this VCam's priority.
## Returns:
##	`int` `main_priority`, if `viewport_rid` is null.
##	`int` `main_priority`, if there is no specific priority for the
##		given viewport.
##	`int` The specific priority for the given viewport, if there was
##		one assigned.
func get_priority_by_rid(viewport_rid: RID) -> int:
	# If we were not given a proper RID, just return the main priority.
	if viewport_rid == null:
		return main_priority
	return _specific_priorities.get(viewport_rid, main_priority)


## Set the priority of this VCam, relative to the viewport using the RID
## of the viewport as reference.
## Args:
##	`viewport_rid`: The resource ID of the Viewport that we want to use
##		as reference when setting this VCam's priority.
##	`priority`: The specific priority value we want to assign for this
##		VCam to report when queried by the given Viewport.
func set_priority_by_rid(viewport_rid: RID, priority: int) -> void:
	if viewport_rid == null:
		return
	_specific_priorities[viewport_rid] = priority


## Does this VCam have a specific priority set for the given viewport,
## using it's RID as reference?
## Args:
##	`viewport_rid`: The resource ID of the Viewport that we want to see
##		if this VCam has a priority set for.
## Returns:
##	`true` if this VCam has a specific priority assigned to the given
##		viewport.
##	`false` otherwise.
func has_priority_by_rid(viewport_rid: RID) -> bool:
	if viewport_rid == null:
		return false
	return _specific_priorities.has(viewport_rid)


## Remove the specific priority that this VCam has for a given viewport
## using the RID of the viewport as reference.
## Args:
##	`viewport_rid`: The resource ID of the Viewport that we want to use
##		as reference when removing this VCam's priority.
## Returns:
##	`true` if the specific priority for the viewport was removed.
##	`false` if there was no specific priority for the viewport.
func remove_priority_by_rid(viewport_rid: RID) -> bool:
	return _specific_priorities.erase(viewport_rid)


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
