extends PlayerControllerScript

#
#	Private Variables
#

## The name of the primary "use item" action. Typically left mouse.
const use_0_action: String = "player_use_item_0"

## The name of the primary "use item" action. Typically right mouse.
const use_1_action: String = "player_use_item_1"

#
#	Player Functions
#

func player_process(_delta: float) -> void:
    # Get the currently selected item and item script. If there isn't one, EXIT EARLY
    var item: ItemInstance = player.item_interactor.selected_item
    if item == null: return
    var item_script = item.get_item_script()
    if item_script == null: return

    # Populate the values for this items input
    _process_item_input(use_0_action, item_script.use_0_input)
    _process_item_input(use_1_action, item_script.use_1_input)
    
#
#   Private Functions
#

## Given some input action and an ItemInput object, fill in the values that the ItemInput
## needs to properly represent the player's input state.
func _process_item_input(action_name: String, input: ItemScriptBase.ItemInput) -> void:
    # If we don't support this input, EXIT EARLY
    if not InputMap.has_action(action_name): return

    input.just_down = Input.is_action_just_pressed(action_name)
    input.pressing = Input.is_action_pressed(action_name)
    input.just_up = Input.is_action_just_released(action_name)