## A node representation of some configurable player input action.
## Making this node based means we can allow a designer in Godot to
## define what Input Actions should be listened for IN EDITOR, rather
## than modifying code.
## The name of this node should be the name of the Input Action to use.
@tool
class_name PlayerInputAnalog
extends PlayerInputAction

#
#   Public Functions
#

## Get the analog strength for this input.
## Returns:
##	A value between 0 and 1, inclusive.
func get_analog_strength() -> float:
	if not InputMap.has_action(name):
		return 0

	return Input.get_action_strength(name)


