class_name PlayerModelAnimParams
extends RefCounted

#
#   Constants
#

const MAIN_STATE_KEY := "parameters/main_state/current_state"
const GROUND_MOVEMENT_BLEND_KEY := "parameters/movement/ground/blend_position"
const MOVEMENT_STATE_TRANSITION_KEY := "parameters/movement/state/transition_request"

#
#   Static Functions
#


static func set_anim_param(
	animation_tree: AnimationTree, param: String, value: Variant
) -> void:
	if not animation_tree:
		return
	animation_tree.set(param, value)


static func set_main_state(
	animation_tree: AnimationTree, value: String
) -> void:
	set_anim_param(animation_tree, MAIN_STATE_KEY, value)


static func set_movement_state(
	animation_tree: AnimationTree, value: String
) -> void:
	set_anim_param(animation_tree, MOVEMENT_STATE_TRANSITION_KEY, value)


static func set_movement_vector(
	animation_tree: AnimationTree, input_movement: Vector2
) -> void:
	set_anim_param(animation_tree, GROUND_MOVEMENT_BLEND_KEY, input_movement)
