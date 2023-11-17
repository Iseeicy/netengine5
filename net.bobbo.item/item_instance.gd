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

## Used to indicate if an item instance operation succeeded, or if there was
## some kind of error.
enum InstanceError {
	OK = 0,					# There is no error.
	UNKNOWN = -1,			# We don't know the error, but there was one.
	ALREADY_EXISTS = -2,	# This item already exists.
	SCENE_MISSING = -3,		# The scene is in the descriptor is missing.
	FILTER_DENIED = -4,		# A filter denied this.
	NO_FIT = -5,			# This didn't fit.
	DIFFERENT_TYPES = -6,	# This item isn't the same type.
}

#
#	Exports
#

## Emitted just as this item is being free'd.
signal item_freed()

## Emitted when the item's stack size changes
signal stack_size_changed(size: int)

#
#	Private Variables
#

## The descriptor that this instance came from.
var _descriptor: ItemDescriptor = null
## Generally where is this object spatially?
var _space_state: SpaceState = SpaceState.NOWHERE
## If this instance is IN_WORLD, then this is the WorldItem that represents us.
var _current_world_item: Node = null
## If this instance is IN_INVENTORY, then this is the ItemInventory that the
## item is currently contained in.
var _current_parent_inventory: ItemInventory = null
## How many items are represented by this instance.
var _current_stack_size: int = 1

#
#	Godot Functions
#

func _notification(what: int):
	# When this object is free'd, remove it from existing anywhere
	if what == NOTIFICATION_PREDELETE:
		self.put_nowhere()
		item_freed.emit()

#
#	Public Functions
#

## Setup this item. Intended to be called by the ItemDescriptor that this item
## belongs to.
func setup(desc: ItemDescriptor) -> void:
	_descriptor = desc
	put_nowhere()

## Returns the ItemDescriptor that this item belongs to.
func get_descriptor() -> ItemDescriptor: return _descriptor

## Returns the current SpaceState of this item.
func get_space_state() -> SpaceState: return _space_state

## If this instance is in the game world, then this returns the object that
## represents it. Otherwise, this returns null
func get_world_item():
	return _current_world_item if _space_state == SpaceState.IN_WORLD else null

## Returns how many items are represented by this instance. Typically for equipment
## this is 1, though for materials this number could increase.
func get_stack_size() -> int: return _current_stack_size

## Set how many items are represented by this instance. Will be clamped between
## 0 and the max stack size.
func set_stack_size(size: int) -> void: 
	_current_stack_size = clampi(size, 0, get_max_stack_size())
	stack_size_changed.emit(_current_stack_size)

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

## Split our stack of items into two stacks. This will create a new item
## instance that is immediately placed nowhere. If the stack can not be split
## and leave items in both the current item stack and new item stack, this will
## return null.
func split_stack(new_stack_size: int) -> ItemInstance:
	if new_stack_size <= 0: return null		# If they don't want any, EXIT EARLY
	if get_stack_size() == 0: return null	# If we don't have any, EXIT EARLY
	
	# If we would use all of or more than what we have, EXIT EARLY
	if get_stack_size() - new_stack_size <= 0: return null
	
	# OTHERWISE, we can split reasonably. Create a new instance
	var new_item = get_descriptor().create_instance()
	self.set_stack_size(self.get_stack_size() - new_stack_size)
	new_item.set_stack_size(new_stack_size)
	
	return new_item
	

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
##	`InstanceError.OK` if the item was placed in the game world
##	`InstanceError.ALREADY_EXISTS` if the item is already in the game world
##	`InstanceError.SCENE_MISSING` if there is no scene in the descriptor for a
##		WorldItem
func put_in_world(world_root: Node = null) -> InstanceError:
	if _space_state == SpaceState.IN_WORLD:
		return InstanceError.ALREADY_EXISTS
	if _descriptor.world_item_scene == null:
		return InstanceError.SCENE_MISSING
	
	# Use the window as world root, if not provided
	if world_root == null: world_root = get_window()
	
	_remove_from_inventory() # Remove from an inventory, if we're in one.
	
	# Spawn and setup the new world item
	var world_item = get_descriptor().world_item_scene.instantiate()
	world_item.setup(self)
	world_root.add_child(world_item)
	_current_world_item = world_item
	
	# Reparent us to the world item to make it easier to visualize where
	# this item is, in the editor.
	_change_parent(_current_world_item)
	
	_space_state = SpaceState.IN_WORLD
	return InstanceError.OK

## Places this item instance in an inventory. If it was in the world, it is
## removed from the game world. If it was in a different inventory, it is
## removed from that inventory.
## Optionally, put it in a specific slot of the inventory.
## Returns:
##	`InstanceError.OK` if the item was place in the inventory
##	`InstanceError.FILTER_DENIED` if the item was rejected by the inventory's
##		filter.
##	`InstanceError.NO_FIT` if the entire item could not fit in the inventory
func put_in_inventory(inventory: ItemInventory, slot: int = -1) -> InstanceError:
	# If we should just put this item anywhere in the inventory....
	if slot == -1:
		# Try to push the item in
		var error = inventory.push_item(self)
		
		# Handle any errors
		if error == ItemInventory.InventoryError.FILTER_DENIED:
			return InstanceError.FILTER_DENIED
		if error == ItemInventory.InventoryError.NO_FIT:
			return InstanceError.NO_FIT
		# Tell us about unhandled errors
		if error != ItemInventory.InventoryError.OK:
			printerr("`put_in_inventory` encountered unknown `push_item` error code %s" % error)
			return InstanceError.UNKNOWN
		
		# Reparent us to the inventory to make it easier to visualize where
		# the item is, in the editor
		_remove_from_inventory()
		_remove_from_world()
		_change_parent(inventory)
		
		_space_state = SpaceState.IN_INVENTORY
		_current_parent_inventory = inventory
		_if_empty_free() 		# Free ourselves if we have no stack left
		return InstanceError.OK	# We pushed correctly!
	# If we should put this item in a specific slot of the inventory...
	else:
		# Try to put the item into the specific slot
		var error = inventory.put_item_in_slot(slot, self)
		
		# Handle any errors
		if error == ItemInventory.InventoryError.FILTER_DENIED:
			return InstanceError.FILTER_DENIED
		if error == ItemInventory.InventoryError.DIFFERENT_TYPES:
			return InstanceError.DIFFERENT_TYPES
		if error == ItemInventory.InventoryError.NO_FIT:
			return InstanceError.NO_FIT
		# Tell us about unhandled errors
		if error != ItemInventory.InventoryError.OK:
			printerr("`put_in_inventory` encountered unknown `put_item_in_slot` error code %s" % error)
			return InstanceError.UNKNOWN
		
		# Reparent us to the inventory to make it easier to visualize where
		# the item is, in the editor
		_remove_from_inventory()
		_remove_from_world()
		_change_parent(inventory)
		
		_space_state = SpaceState.IN_INVENTORY
		_current_parent_inventory = inventory
		_if_empty_free() 		# Free ourselves if we have no stack left
		return InstanceError.OK	# We put correctly!

## Places this item back into a limbo state, existing mostly just in memory.
## If it was in the world, it is removed from the game world. If it was in an
## inventory, it is removed from that inventory.
func put_nowhere() -> void:
	_remove_from_world()		# Make sure we're no longer in the world
	_remove_from_inventory()	# Make sure we're no longer in an inventory
	
	# Place us into the item VOID plane
	_space_state = SpaceState.NOWHERE
	_change_parent(null)

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
	_space_state = SpaceState.NOWHERE
	return slot_index != -1

## Remove this instance from the game world, if it's placed there.
## Returns:
##	`true` if it was removed from the world, and the WorldItem was free'd
##	`false` if there was no WorldItem, and we're not in the game world.
func _remove_from_world() -> bool:
	if _current_world_item == null:
		return false
		
	_current_world_item.queue_free()
	_current_world_item = null
	_space_state = SpaceState.NOWHERE
	return true

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

func _change_parent(new_parent):
	if get_parent() != null:
		if new_parent == null:
			get_parent().remove_child(self)
		else:
			reparent(new_parent)
	elif new_parent != null:
		new_parent.add_child(self)
