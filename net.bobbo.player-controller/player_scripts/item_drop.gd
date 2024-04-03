extends PlayerControllerScript

#
#	Constants
#

## The key for the "drop a single item" action
const DROP_ITEM_SINGLE_ACTION: String = "player_drop_item_single"

## The key for the "drop a whole item stack" action
const DROP_ITEM_STACK_ACTION: String = "player_drop_item_stack"

#
#	Exported
#

## How much forward force to apply when dropping an item.
@export var drop_impulse: float = 3

#
#	Player Functions
#


func character_agent_physics_process(_delta: float):
	# Run logic for dropping a single item
	if agent_3d.input.is_action_just_pressed(DROP_ITEM_SINGLE_ACTION):
		drop_item(player.item_interactor.selected_slot, 1)

	# Run logic for dropping a whole stack
	if agent_3d.input.is_action_just_pressed(DROP_ITEM_STACK_ACTION):
		drop_item(player.item_interactor.selected_slot)


#
#   Public Functions
#


## Makes the player drop an item from their inventory into the 3D game
## world. If `stack_size` is larger than what is actually at
## `item_index`, then the whole stack will be dropped.
## Returns:
##  `ItemInstance` of the dropped item or split stack if everything
##      worked.
##  `null` if `item_index` is out of the inventory bounds.
##  `null` if there's no item to drop.
##  `null` if `ItemInstance.put_in_world_3d()` doesn't return OK
func drop_item(item_index: int, stack_size: int = -1) -> ItemInstance:
	# If we're trying to use an index that's outta bounds, EXIT EARLY.
	if item_index < 0 or item_index >= player.inventory.size:
		return null

	# If we're not trying to drop ANY items for some reason, EXIT EARLY.
	if stack_size == 0:
		return null

	# Find the item to drop in our inventory. If there isn't one at that
	# slot, EXIT EARLY
	var item_to_drop = player.inventory.get_item_at_slot(item_index)
	if item_to_drop == null:
		return null

	# If we have a specific stack size we wanna drop, split the stack
	# and use that instead
	if stack_size > 0:
		var the_split_stack = item_to_drop.split_stack(stack_size)
		if the_split_stack != null:
			item_to_drop = the_split_stack

	# Put the item in the world. If theres a problem, EXIT EARLY
	var err = item_to_drop.put_in_world_3d(get_window())
	if err != ItemInstance.InstanceError.OK:
		return null

	# Start the pickup timer, so we don't accidentally re-pick up this
	# item
	item_to_drop.get_world_item_3d().start_pickup_timer()

	# Make it so the item comes out of the player's facing direction
	var world_item = item_to_drop.get_world_item_3d()
	world_item.global_position = player.camera.global_position
	if not world_item.lock_rotation:
		world_item.global_rotation = player.camera.global_rotation
	world_item.apply_impulse(
		-player.camera.global_transform.basis.z * drop_impulse
	)

	return item_to_drop
