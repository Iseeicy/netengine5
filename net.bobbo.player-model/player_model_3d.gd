## A 3D PlayerModel. This should be the root for any 3D PlayerModel
## scene. Controls the visual and animation state of a playermodel.
## Intended to be used and instantiated by PlayerModelRenderer3D.
class_name PlayerModel3D
extends Node3D

#
#   Exports
#

## The animation controller for this playermodel.
@export var animation_tree: AnimationTree = null

#
#   Public Functions
#


## Not intended to be called directly. Call through
## `PlayerModelRenderer3D.set_anim_param()`.
func set_anim_param(param: String, value: Variant) -> void:
	PlayerModelAnimParams.set_anim_param(animation_tree, param, value)


## Not intended to be called directly. Call through
## `PlayerModelRenderer3D.set_main_state()`.
func set_main_state(value: String) -> void:
	PlayerModelAnimParams.set_main_state(animation_tree, value)


## Not intended to be called directly. Call through
## `PlayerModelRenderer3D.set_movement_state()`.
func set_movement_state(value: String) -> void:
	PlayerModelAnimParams.set_movement_state(animation_tree, value)


## Not intended to be called directly. Call through
## `PlayerModelRenderer3D.set_movement_vector()`.
func set_movement_vector(input_movement: Vector2) -> void:
	PlayerModelAnimParams.set_movement_vector(animation_tree, input_movement)


## Not intended to be called directly. Call through
## `PlayerModelRenderer3D.fire_oneshot()`.
func fire_oneshot(param: String) -> void:
	PlayerModelAnimParams.fire_oneshot(animation_tree, param)
