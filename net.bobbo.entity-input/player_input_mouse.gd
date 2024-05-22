## A node representation of some configurable mouse movement action.
## Making this node based means we can allow a designer in Godot to
## define what Input Actions should be listened for IN EDITOR, rather
## than modifying code.
## The name of this node should be the name of the Input Action to use.
##
## Thanks a ton to https://yosoyfreeman.github.io/ for the amazing insights
## on attaining good mouselook in Godot!
@tool
class_name PlayerInputMouse
extends Node

#
#	Exports
#

## The name of the analog action to use when looking up
@export var up_action_name: String = BobboInputs.Player.Look.UP

## The name of the analog action to use when looking down
@export var down_action_name: String = BobboInputs.Player.Look.DOWN

## The name of the analog action to use when looking left
@export var left_action_name: String = BobboInputs.Player.Look.LEFT

## The name of the analog action to use when looking right
@export var right_action_name: String = BobboInputs.Player.Look.RIGHT

## Should we ignore mouse events if the mouse is not captured by the window?
@export var ignore_when_uncaptured := true

#
#	Private Variables
#

var _accumulated_process_input: Vector2 = Vector2.ZERO
var _accumulated_physics_input: Vector2 = Vector2.ZERO

#
#	Godot Functions
#


func _input(event):
	# If the mouse isn't captured, ignore this event
	if (
		Input.mouse_mode != Input.MOUSE_MODE_CAPTURED
		and ignore_when_uncaptured
	):
		return

	# If the mouse moved, store this movement to process later
	if event is InputEventMouseMotion:
		# Get the viewport and use that to scale the input correctly
		var transformed_relative = (
			event.xformed_by(get_tree().root.get_final_transform()).relative
		)

		_accumulated_process_input += transformed_relative
		_accumulated_physics_input += transformed_relative


#
#   Public Functions
#


## Read the accumulated mouse movement values for a specific tick type
func read_accumulated(tick_type: EntityInput.TickType) -> Vector2:
	if tick_type == EntityInput.TickType.PROCESS:
		return _accumulated_process_input
	if tick_type == EntityInput.TickType.PROCESS_PHYSICS:
		return _accumulated_physics_input

	return Vector2.ZERO


## Clear any accumulated mouse movement values from a specific tick type
func clear_accumulated(tick_type: EntityInput.TickType) -> void:
	if tick_type == EntityInput.TickType.PROCESS:
		_accumulated_process_input = Vector2.ZERO
	if tick_type == EntityInput.TickType.PROCESS_PHYSICS:
		_accumulated_physics_input = Vector2.ZERO
