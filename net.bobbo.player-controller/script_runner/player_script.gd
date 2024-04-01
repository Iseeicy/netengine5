extends CharacterAgentScript
class_name PlayerControllerScript

#
#	Public Variables
#

## The PlayerController that this script belongs to.
var player: PlayerController:
	get:
		if player == null: player = agent as PlayerController
		return player

#
#	Public Functions
#

## Try to assert that the Godot Project has a given Input
## Action configured. If the InputMap is missing that
## Action, then an error is printed and this script
## will not run.
func assert_input_action(action_name: String) -> bool:
	if InputMap.has_action(action_name):
		return true
	else:
		printerr("No input defined for '%s'. %s stopped..." % [action_name, self.name])
		self.set_running(false)
		return false
