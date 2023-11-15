@tool
extends Node
class_name ItemInstance

#
#	Types
#

## The state of an item's existence in space.
enum SpaceState {
	NOWHERE = 0,		# This item doesn't exist anywhere other than in memory!
	IN_INVENTORY = 1,	# This item is in an inventory somewhere.
	IN_WORLD = 2,		# This item is in the game world somewhere.
}



#
#	Private Variables
#

var _descriptor: ItemDescriptor = null
## Generally where is this object spatially?
var _space_state: SpaceState = SpaceState.NOWHERE
## If this instance is IN_WORLD, then this is the WorldItem that represents us.
var _current_world_item: WorldItem = null
## If this instance is IN_INVENTORY, then this is the ItemInventory that the
## item is currently contained in.
var _current_parent_inventory: ItemInventory = null
## How many items are represented by this instance.
var _current_stack_size: int = 1

#
#	Godot Functions
#

func _exit_tree():
	# When this object is free'd, remove it from existing anywhere
	self.put_nowhere()

#
#	Public Functions
#

## Setup this item. Intended to be called by the ItemDescriptor that this item
## belongs to.
func setup(desc: ItemDescriptor) -> void:
	_descriptor = desc

## Returns the ItemDescriptor that this item belongs to.
func get_descriptor() -> ItemDescriptor: return _descriptor

## Returns the current SpaceState of this item.
func get_space_state() -> SpaceState: return _space_state

## If this instance is in the game world, then this returns the object that
## represents it. Otherwise, this returns null
func get_world_item() -> WorldItem:
	return _current_world_item if _space_state == SpaceState.IN_WORLD else null

## Returns how many items are represented by this instance. Typically for equipment
## this is 1, though for materials this number could increase.
func get_stack_size() -> int: return _current_stack_size

## Set how many items are represented by this instance. Will be clamped between
## 0 and the max stack size.
func set_stack_size(size: int) -> void: 
	_current_stack_size = clampi(size, 0, get_max_stack_size())

## Returns how many items can possibly be fit in this instance.
func get_max_stack_size() -> int: return _descriptor.max_stack_size

## Returns how many items can still fit in this instance
func get_stack_space_left() -> int: return get_max_stack_size() - get_stack_size()

## Is this stack of items full?
func is_stack_full() -> bool: return get_stack_size() >= _descriptor.max_stack_size

## Merge our stack of items into another given stack of items. It's up to
## whatever calls this to interpret the aftermath. This allows our item to
## go to 0 stack size, which means it should be removed.
func merge_stack_into(item: ItemInstance) -> void:
	if item.get_descriptor() != self.get_descriptor():
		return
	
	# Fit as much as we can into the given item
	var can_fit_count = min(self.get_stack_size(), item.get_stack_space_left())
	item.set_stack_size(item.get_stack_size() + can_fit_count)
	
	# Subtract from our stack size
	self.set_stack_size(self.get_stack_size() - can_fit_count)


## Spawn and return a new instance of this item's view model, if there is one. 
## Returns null if there isn't one
func instantiate_view_model() -> ItemViewModel:
	if _descriptor.view_model_scene == null:
		return null
	
	var new_view_model = _descriptor.view_model_scene.instantiate()
	new_view_model.setup(self)
	return new_view_model

## Places this item instance in the game world. If it was in an inventory, it is
## removed from that inventory.
## Returns
## - `true` if the item was placed in the game world
## - `false` if the item is already in the game world
## - `false` if there is no scene in the descriptor for a WorldItem
func put_in_world() -> bool:
	if _space_state == SpaceState.IN_WORLD:
		return false
	if _descriptor.world_item_scene == null:
		return false
	
	_remove_from_inventory() # Remove from an inventory, if we're in one.
	
	# Spawn and setup the new world item
	var world_item: WorldItem = get_descriptor().world_item_scene.instantiate()
	world_item.setup(self)
	_current_world_item = world_item
	return true

## Places this item instance in an inventory. If it was in the world, it is
## removed from the game world. If it was in a different inventory, it is
## removed from that inventory.
## Optionally, put it in a specific slot of the inventory.
## Returns:
## - `true` if the item was place in the inventory
## - `false` if the item was rejected by the inventory's filter
## - `false` if the entire item could not fit in the inventory
func put_in_inventory(inventory: ItemInventory, slot: int = -1) -> bool:
	# TODO
	# CONTINUE HERE. This will use either put item in slot or push item
	# depending on what slot is. We need to handle removing object upon push if it
	# gets totally merged too. Perhaps this func should have an enum return type
	# for better info?
	
	# If we should just put this item anywhere in the inventory....
	if slot == -1:
		# Try to push the item in
		var error = inventory.push_item(self)
		
		# Handle any errors
		if error == ItemInventory.InventoryError.FILTER_DENIED:
			return false
		if error == ItemInventory.InventoryError.NO_FIT:
			return false
		# Tell us about unhandled errors
		if error != ItemInventory.InventoryError.OK:
			printerr("`put_in_inventory` encountered unknown `push_item` error code %s" % error)
			return false
		
		_if_empty_free() 	# Free ourselves if we have no stack left
		return true			# We pushed correctly!
	# If we should put this item in a specific slot of the inventory...
	else:
		# Try to put the item into the specific slot
		var error = inventory.put_item_in_slot(slot, self)
		
		# Handle any errors
		if error == ItemInventory.InventoryError.FILTER_DENIED:
			return false
		if error == ItemInventory.InventoryError.SLOT_OCCUPIED:
			return false
		# Tell us about unhandled errors
		if error != ItemInventory.InventoryError.OK:
			printerr("`put_in_inventory` encountered unknown `put_item_in_slot` error code %s" % error)
			return false
		
		pass
	
	return false

## Places this item back into a limbo state, existing mostly just in memory.
## If it was in the world, it is removed from the game world. If it was in an
## inventory, it is removed from that inventory.
func put_nowhere() -> void:
	# TODO
	return

#
#	Private Functions
#

## Remove this instance from it's parent inventory, if it's in one.
## Returns:
## `true` if it was removed from an inventory
## `false` if there was nothing to remove it from
func _remove_from_inventory() -> bool:
	if _current_parent_inventory == null:
		return false
		
	var slot_index = _current_parent_inventory.find(self)
	if slot_index != -1:
		_current_parent_inventory.take_item_from_slot(slot_index)
	_current_parent_inventory = null
	return slot_index != -1

## Checks to see if there's any items left in this stack. If there isn't, then
## this instance will be free'd.
## Returns:
## - `true` if there's nothing left and we are being free'd
## - `false` if there's still items in this stack
func _if_empty_free() -> bool:
	if get_stack_size() > 0:
		return false
	# If we have no items, then queue up our freeing!
	queue_free()
	return true
