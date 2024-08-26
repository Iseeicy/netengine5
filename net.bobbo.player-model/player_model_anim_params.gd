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


## Assigns the value of some animation parameter.
## Args:
## 	`animation_tree`: The AnimationTree to work with. If null, does nothing.
## 	`param`: The key of the animation parameter to set.
## 	`value`: The value to assign to the animation parameter.
static func set_anim_param(
	animation_tree: AnimationTree, param: String, value: Variant
) -> void:
	if not animation_tree:
		return
	animation_tree.set(param, value)


## Assigns the value of an AnimationTree's main_state transition.
## Args:
## 	`animation_tree`: The AnimationTree to work with. If null, does nothing.
## 	`value`: The value to assign to main_state. Should be something like
##		"in_control", "sitting", etc.
static func set_main_state(
	animation_tree: AnimationTree, value: String
) -> void:
	set_anim_param(animation_tree, MAIN_STATE_KEY, value)


## Assigns the value of an AnimationTree's movement state transition.
## Args:
## 	`animation_tree`: The AnimationTree to work with. If null, does nothing.
## 	`value`: The value to assign to movement/state. Should be something like
##		"ground", "air", etc.
static func set_movement_state(
	animation_tree: AnimationTree, value: String
) -> void:
	set_anim_param(animation_tree, MOVEMENT_STATE_TRANSITION_KEY, value)


## Assigns multiple generic parameters based on player movement.
## Args:
## 	`animation_tree`: The AnimationTree to work with. If null, does nothing.
## 	`input_movement`: The movement vector to assign. If facing forward, X is
##		left to right and Y is forward to backward.
static func set_movement_vector(
	animation_tree: AnimationTree, input_movement: Vector2
) -> void:
	set_anim_param(animation_tree, GROUND_MOVEMENT_BLEND_KEY, input_movement)
