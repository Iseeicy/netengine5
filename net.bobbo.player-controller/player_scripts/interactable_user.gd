## Allows players to "use" `Interactables` focused by the player's 
## `InteractorRay3D` with the `player_interact` input.
extends PlayerControllerScript

#
#	Private Variables
#

## The name of the "use interactable" action. Typically the E key.
const use_action: String = "player_interact"

#
#	Player Functions
#

func player_process(_delta: float) -> void:
    # If the player is NOT hovering over something right now, EXIT EARLY
    if not player.interactor.is_hovering: return
    # If we don't even have a use key, EXIT EARLY
    if not InputMap.has_action(use_action): return

    # Cache all of the interactables to use below
    var interactables = player.interactor.get_focused_interactables()

    # If we're just now pressing the use key, call all of the use start funcs.
    if Input.is_action_just_pressed(use_action):
        for inter in interactables: inter.call_use_start()
    # If we're just now releasing the use key, call all of the use stop funcs.
    if Input.is_action_just_released(use_action):
        for inter in interactables: inter.call_use_stop()
