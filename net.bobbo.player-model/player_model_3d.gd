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


func set_anim_param(param: String, value: Variant) -> void:
	PlayerModelAnimParams.set_anim_param(animation_tree, param, value)


func set_main_state(value: String) -> void:
	PlayerModelAnimParams.set_main_state(animation_tree, value)


func set_movement_state(value: String) -> void:
	PlayerModelAnimParams.set_movement_state(animation_tree, value)


func set_movement_vector(input_movement: Vector2) -> void:
	PlayerModelAnimParams.set_movement_vector(animation_tree, input_movement)
