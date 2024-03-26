extends Node
class_name ItemInteractor
# TODO - Optionally different behavior for when a selected item is removed.

#
#   Exports
#

## Emitted when the selected slot has changed. Will be -1 if no slot selected.
signal slot_selected(item_index: int)

#
#   Public Variables
#

## The inventory that this will use for interacting.
var inventory: ItemInventory:
    get:
        return _target_inventory
    set(value):
        # If this is the same inventory, EXIT EARLY
        if _target_inventory == value: return
        
        # If we had an inventory before, disconnect it's events.
        if _target_inventory != null:
            _target_inventory.slot_updated.disconnect(_on_inventory_slot_updated.bind())
        
        _target_inventory = value

        # If we have an inventory now, connect it's events.
        if _target_inventory:
            _target_inventory.slot_updated.connect(_on_inventory_slot_updated.bind())

        _set_selected_slot_index_helper( - 1)

## The currently selected slot index. If no slot is selected or there
## is no inventory, this is -1.
var selected_slot: int:
    get:
        if inventory == null:
            return - 1
        else:
            return _selected_slot_index

## The currently selected item. If nothing is selected, this is null.
var selected_item: ItemInstance:
    get:
        if inventory == null:
            return null
        else:
            return inventory.get_item_at_slot(selected_slot)

#
#   Private Variables
#

## The inventory to interact with. Gated behind a getter/setter so
## that we can automatically handle updating signals upon setting.
var _target_inventory: ItemInventory = null
## The index of the selected slot in `inventory`. -1 if there is nothing
## selected.
var _selected_slot_index: int = -1

#
#   Public Functions
#

## Selects a slot in the inventory.
## Args:
##  `item_index`: The index of the slot to select.
## Returns:
##  `ItemInstance` if a slot was selected that contains a valid item.
##  `null` if a slot was selected that is empty.
##  `null` if there is no inventory currently set.
##  `null` if `item_index` was out of `inventory`'s bounds.
func set_selected_slot(item_index: int) -> ItemInstance:
    # If we don't have an inventory, we select nothing. EXIT EARLY.
    if inventory == null:
        _set_selected_slot_index_helper( - 1)
        return null

    # If we try to select something outside of the inventory's bounds,
    # then EXIT EARLY.
    if item_index < 0 or item_index > inventory.size:
        _set_selected_slot_index_helper( - 1)
        return null

    # OTHERWISE - we are selecting something IN BOUNDS, so... do it!
    _set_selected_slot_index_helper(item_index)
    return inventory.get_item_at_slot(item_index)

#
#   Signals
#

## Called when the connect inventory has a slot's contents updated.
func _on_inventory_slot_updated(index: int, item: ItemInstance) -> void:
    # If the selected item no longer has an item in that slot, then try
    # to select another
    if index == _selected_slot_index and item == null:
        # Try and find a slot before the previously selected item
        var new_index = inventory.find_filled_slot_before(_selected_slot_index)
        
        # If we can't find one, find a slot after the previously selected item
        if new_index == - 1:
            new_index = inventory.find_filled_slot_after(_selected_slot_index)

        # If we did or didn't find one, set our selected index regardless
        _set_selected_slot_index_helper(new_index)

#
#   Private Functions
#

## A helper function that only sets the selected item index and emits an
## event if a new value is being assigned.
func _set_selected_slot_index_helper(new_index: int) -> void:
    if _selected_slot_index == new_index: return
    _selected_slot_index = new_index
    slot_selected.emit(new_index)