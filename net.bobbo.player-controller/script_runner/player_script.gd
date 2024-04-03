class_name PlayerControllerScript
extends CharacterAgentScript

#
#	Public Variables
#

## The PlayerController that this script belongs to.
var player: PlayerController:
	get:
		if player == null:
			player = agent as PlayerController
		return player
