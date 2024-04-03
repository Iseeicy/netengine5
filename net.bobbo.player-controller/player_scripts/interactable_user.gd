## Allows players to "use" `Interactables` focused by the player's
## `InteractorRay3D` with the `player_interact` input.
extends PlayerControllerScript

#
#	Constants
#

## The name of the "use interactable" action. Typically the E key.
const USE_ACTION: String = "player_interact"

#
#	Player Functions
#


func character_agent_process(_delta: float) -> void:
	# If the player is NOT hovering over something right now, EXIT EARLY
	if not player.interactor.is_hovering:
		return

	# Cache all of the interactables to use below
	var interactables = player.interactor.get_focused_interactables()

	# If we're just now pressing the use key, call all of the use start
	## funcs.
	if agent_3d.input.is_action_just_pressed(USE_ACTION):
		for inter in interactables:
			inter.call_use_start()
	# If we're just now releasing the use key, call all of the use stop
	## funcs.
	if agent_3d.input.is_action_just_released(USE_ACTION):
		for inter in interactables:
			inter.call_use_stop()
