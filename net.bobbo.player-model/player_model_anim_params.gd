## A static class that unifies the AnimationTree manipulation between
## PlayerModel2D and PlayerModel3D. The core functionality of setting
## animation parameters is implemented here, so that these
## implementations can be re-used across PlayerModel nodes.
class_name PlayerModelAnimParams
extends RefCounted

#
#   Constants
#

## The property path of the main AnimationTree state. This points to a
## Transition node with the name `current_state`.
const MAIN_STATE_KEY := "parameters/main_state/current_state"

## The property path of the AnimationTree's ground movement blendspace.
## This points to a BlendSpace2D node with the name `ground`, underneath
## a BlendTree named `movement`.
const GROUND_MOVEMENT_BLEND_KEY := "parameters/movement/ground/blend_position"

## The property path of the AnimationTree's movement state. This points
## to a Transition node with the name `state`, underneath a BlendTree
## named `movement`.
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
	if animation_tree:
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


## Fires a oneshot animation node.
## Args:
## 	`animation_tree`: The AnimationTree to work with. If null, does nothing.
## 	`param`: The key of the oneshot node's request parameter.
static func fire_oneshot(animation_tree: AnimationTree, param: String) -> void:
	if animation_tree:
		animation_tree.set(param, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
