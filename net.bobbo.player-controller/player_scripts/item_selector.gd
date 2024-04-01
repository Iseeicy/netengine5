extends PlayerControllerScript

#
#	Private Variables
#

## The key for "scroll to the next item" action
const _scroll_item_forward_action: String = "player_scroll_item_forward"
var _scroll_item_forward_pressed: bool:
    get:
        return InputMap.has_action(_scroll_item_forward_action) and Input.is_action_just_pressed(_scroll_item_forward_action)
        
## The key for "scroll to the previous item" action
const _scroll_item_back_action: String = "player_scroll_item_back"
var _scroll_item_back_pressed: bool:
    get:
        return InputMap.has_action(_scroll_item_back_action) and Input.is_action_just_pressed(_scroll_item_back_action)

#
#	Player Functions
#

func player_process(_delta: float):
    # Run the logic for selecting the next item
    if _scroll_item_forward_pressed: select_next_item()

    # Run the logic for selecting the previous item
    if _scroll_item_back_pressed: select_previous_item()

#
#   Public Functions
#

## Select the next item in the inventory. If no item is selected, then 
## this will select the first item.
func select_next_item() -> ItemInstance:
    var start_index = _get_search_start_index()
    var next_index = player.inventory.find_filled_slot_after(start_index, true)
    return player.item_interactor.set_selected_slot(next_index)

## Select the previous item in the inventory. If no item is selected, 
## then this will select the last item.
func select_previous_item() -> void:
    var start_index = _get_search_start_index()
    var prev_index = player.inventory.find_filled_slot_before(start_index, true)
    return player.item_interactor.set_selected_slot(prev_index)

#
#   Private Functions
#

## Get the index where item searching should start.
func _get_search_start_index() -> int:
    if player.item_interactor.selected_slot < 0:
        return 0
    else:
        return player.item_interactor.selected_slot
