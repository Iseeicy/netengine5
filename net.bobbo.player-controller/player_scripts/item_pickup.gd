extends PlayerControllerScript

#
#   Private Variables
#

@onready var _pickup_area: Area3D = $ItemPickupArea3D
var _items_that_could_be_picked_up: Array[WorldItem3D] = []

#
#   Player Functions
#

func player_ready() -> void:
    # Put the pickup area under a 3D node
    _pickup_area.reparent(player, false)

func player_physics_process(_delta: float) -> void:
    # Try to pickup any cached items that couldn't be picked up before, but MAYBE could be now
    for item in _items_that_could_be_picked_up:
        _attempt_pickup_item(item)

#
#   Private Functions
#

## Try to pick up the given item.
## Args:
##  `item`: The WorldItem to try and pick up.
## Returns:
##  `true` if the item was picked up.
##  `false` if the item could not be picked up.
func _attempt_pickup_item(item: WorldItem3D) -> bool:
    # If we can NOT pick up this item, EXIT EARLY
    if not item.can_pickup: return false

    # Try to put the item in the player's inventory
    var err = item.get_item_instance().put_in_inventory(player.inventory)

    # If we can't fit the item in, EXIT EARLY
    if err != ItemInstance.InstanceError.OK: return false

    # OTHERWISE - we picked up the item. yay!
    return true

#
#   Signals
#

func _on_item_pickup_area_3d_body_entered(body: Node3D):
    # If this body is NOT a WorldItem, EXIT EARLY
    if not (body is WorldItem3D): return

    # Try to pick up the item
    var could_pickup = _attempt_pickup_item(body)

    # If we couldn't pick up the item NOW, cache the item
    # in a list to be re-checked to see if we CAN pick it up
    # later.
    if not could_pickup: _items_that_could_be_picked_up.append(body)

func _on_item_pickup_area_3d_body_exited(body: Node3D):
    # If this body is NOT a WorldItem, EXIT EARLY
    if not (body is WorldItem3D): return

    # Remove this item from the cache of items to re-check, if
    # necessary.
    _items_that_could_be_picked_up.erase(body)