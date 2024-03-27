@tool
extends Node
class_name ItemInstance

#
#	Types
#

## The state of an item's existence in space.
enum SpaceState {
	NOWHERE = 0, # This item doesn't exist anywhere other than in memory!
	IN_INVENTORY = 1, # This item is in an inventory somewhere.
	IN_WORLD_2D = 2, # This item is in the 2D game world somewhere.
	IN_WORLD_3D = 3, # This item is in the 3D game world somewhere.
}

## Used to indicate if an item instance operation succeeded, or if there was
## some kind of error.
enum InstanceError {
	OK = 0, # There is no error.
	UNKNOWN = -1, # We don't know the error, but there was one.
	ALREADY_EXISTS = -2, # This item already exists.
	SCENE_MISSING = -3, # The scene is in the descriptor is missing.
	FILTER_DENIED = -4, # A filter denied this.
	NO_FIT = -5, # This didn't fit.
	DIFFERENT_TYPES = -6, # This item isn't the same type.
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
## The scripting for this item, if any.
var _item_script: ItemScriptBase = null
## Generally where is this object spatially?
var _space_state: SpaceState = SpaceState.NOWHERE
## If this instance is IN_WORLD_2D, then this is the WorldItem that represents us.
var _current_world_item_2d: WorldItem2D = null
## If this instance is IN_WORLD_3D, then this is the WorldItem that represents us.
var _current_world_item_3d: WorldItem3D = null
## All 2D viewmodels that have been spawned
var _current_viewmodels_2d: Array[ItemViewModel2D] = []
## All 3D viewmodels that have been spawned
var _current_viewmodels_3d: Array[ItemViewModel3D] = []
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

	# Spawn the scripting for this item as a child
	if desc.item_script_scene != null:
		_item_script = desc.item_script_scene.instantiate()
		add_child(_item_script)
		_item_script.setup(self)

	put_nowhere()

## Returns the ItemDescriptor that this item belongs to.
func get_descriptor() -> ItemDescriptor: return _descriptor

## Returns the scripting for this item if it has any. `null` otherwise.
func get_item_script() -> ItemScriptBase: return _item_script

## Returns the current SpaceState of this item.
func get_space_state() -> SpaceState: return _space_state

## If this instance is in the 2D game world, then this returns the object that
## represents it. Otherwise, this returns null
func get_world_item_2d() -> WorldItem2D:
	return _current_world_item_2d if _space_state == SpaceState.IN_WORLD_2D else null

## If this instance is in the 3D game world, then this returns the object that
## represents it. Otherwise, this returns null
func get_world_item_3d() -> WorldItem3D:
	return _current_world_item_3d if _space_state == SpaceState.IN_WORLD_3D else null

## Returns how many items are represented by this instance. Typically for equipment
## this is 1, though for materials this number could increase.
func get_stack_size() -> int: return _current_stack_size

## Set how many items are represented by this instance. Will be clamped between
## 0 and the max stack size.
func set_stack_size(size: int) -> void:
	var new_stack_size = clampi(size, 0, get_max_stack_size())
	if new_stack_size == _current_stack_size: return

	_current_stack_size = new_stack_size
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
	if new_stack_size <= 0: return null # If they don't want any, EXIT EARLY
	if get_stack_size() == 0: return null # If we don't have any, EXIT EARLY
	
	# If we would use all of or more than what we have, EXIT EARLY
	if get_stack_size() - new_stack_size <= 0: return null
	
	# OTHERWISE, we can split reasonably. Create a new instance
	var new_item = get_descriptor().create_instance()
	self.set_stack_size(self.get_stack_size() - new_stack_size)
	new_item.set_stack_size(new_stack_size)
	
	return new_item

## Spawn and return a new instance of this item's view model, if there is one. 
## Returns null if there isn't one. Otherwise, returns an ItemViewModel2D.
func instantiate_view_model_2d() -> ItemViewModel2D:
	if _descriptor.view_model_2d_scene == null:
		return null
	
	var new_view_model = _descriptor.view_model_2d_scene.instantiate()
	new_view_model.setup(self)

	# Put this viewmodel in the cache of existing viewmodels, and configure it
	# so that it will be removed from the cache when the viewmodel is free'd.
	_current_viewmodels_2d.append(new_view_model)
	var remove_when_free_func = func():
		_current_viewmodels_2d.erase(new_view_model)
	new_view_model.view_model_freed.connect(remove_when_free_func.bind())

	return new_view_model

## Spawn and return a new instance of this item's view model, if there is one. 
## Returns null if there isn't one. Otherwise, returns an ItemViewModel3D.
func instantiate_view_model_3d() -> ItemViewModel3D:
	if _descriptor.view_model_3d_scene == null:
		return null
	
	var new_view_model = _descriptor.view_model_3d_scene.instantiate()
	new_view_model.setup(self)

	# Put this viewmodel in the cache of existing viewmodels, and configure it
	# so that it will be removed from the cache when the viewmodel is free'd.
	_current_viewmodels_3d.append(new_view_model)
	var remove_when_free_func = func():
		_current_viewmodels_3d.erase(new_view_model)
	new_view_model.view_model_freed.connect(remove_when_free_func.bind())
	
	return new_view_model

## Sets an animation parameter in every viewmodel that exists for this specific item instance.
## Args:
## 	`param_key`: The raw key for the AnimationTree parameter to set. If this doesn't match
## 		a valid param, nothing will happen.
## 	`param_value`: The value to set the param to, if found.
func set_viewmodel_anim_param(param_key: String, param_value: Variant) -> void:
	for viewmodel_3d in _current_viewmodels_3d:
		viewmodel_3d.animation_tree.set(param_key, param_value)
	for viewmodel_2d in _current_viewmodels_2d:
		viewmodel_2d.animation_tree.set(param_key, param_value)

## Places this item instance in the 2D game world. If it was in an inventory, it is
## removed from that inventory.
## Returns
##	`InstanceError.OK` if the item was placed in the game world
##	`InstanceError.ALREADY_EXISTS` if the item is already in the 2D or 3D game world
##	`InstanceError.SCENE_MISSING` if there is no scene in the descriptor for a
##		WorldItem
func put_in_world_2d(world_root: Node=null) -> InstanceError:
	if _space_state == SpaceState.IN_WORLD_2D:
		return InstanceError.ALREADY_EXISTS
	if _space_state == SpaceState.IN_WORLD_3D:
		return InstanceError.ALREADY_EXISTS
	if _descriptor.world_item_2d_scene == null:
		return InstanceError.SCENE_MISSING
	
	# Use the window as world root, if not provided
	if world_root == null: world_root = get_window()
	_remove_from_inventory() # Remove from an inventory, if we're in one.

	# Spawn and setup the new 2D world item
	var world_item = get_descriptor().world_item_2d_scene.instantiate()
	world_item.setup(self)
	world_root.add_child(world_item)
	_current_world_item_2d = world_item

	# Reparent us to the world item to make it easier to visualize where
	# this item is, in the editor.
	_change_parent(_current_world_item_2d)

	_space_state = SpaceState.IN_WORLD_2D
	return InstanceError.OK

## Places this item instance in the 3D game world. If it was in an inventory, it is
## removed from that inventory.
## Returns
##	`InstanceError.OK` if the item was placed in the game world
##	`InstanceError.ALREADY_EXISTS` if the item is already in the 2D or 3D game world
##	`InstanceError.SCENE_MISSING` if there is no scene in the descriptor for a
##		WorldItem
func put_in_world_3d(world_root: Node=null) -> InstanceError:
	if _space_state == SpaceState.IN_WORLD_2D:
		return InstanceError.ALREADY_EXISTS
	if _space_state == SpaceState.IN_WORLD_3D:
		return InstanceError.ALREADY_EXISTS
	if _descriptor.world_item_3d_scene == null:
		return InstanceError.SCENE_MISSING
	
	# Use the window as world root, if not provided
	if world_root == null: world_root = get_window()
	_remove_from_inventory() # Remove from an inventory, if we're in one.

	# Spawn and setup the new 3D world item
	var world_item = get_descriptor().world_item_3d_scene.instantiate()
	world_item.setup(self)
	world_root.add_child(world_item)
	_current_world_item_3d = world_item

	# Reparent us to the world item to make it easier to visualize where
	# this item is, in the editor.
	_change_parent(_current_world_item_3d)

	_space_state = SpaceState.IN_WORLD_3D
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
func put_in_inventory(inventory: ItemInventory, slot: int=- 1) -> InstanceError:
	# If we should just put this item anywhere in the inventory....
	if slot == - 1:
		# Try to push the item in
		var error = inventory._push_item(self)
		
		# Handle any errors
		if error == ItemInventory.InventoryError.FILTER_DENIED:
			return InstanceError.FILTER_DENIED
		if error == ItemInventory.InventoryError.NO_FIT:
			return InstanceError.NO_FIT
		# Tell us about unhandled errors
		if error != ItemInventory.InventoryError.OK:
			printerr("`put_in_inventory` encountered unknown `_push_item` error code %s" % error)
			return InstanceError.UNKNOWN
		
		# Reparent us to the inventory to make it easier to visualize where
		# the item is, in the editor
		_remove_from_inventory()
		_remove_from_world()
		_change_parent(inventory)
		
		_space_state = SpaceState.IN_INVENTORY
		_current_parent_inventory = inventory
		_if_empty_free() # Free ourselves if we have no stack left
		return InstanceError.OK # We pushed correctly!
	# If we should put this item in a specific slot of the inventory...
	else:
		# Try to put the item into the specific slot
		var error = inventory._put_item_in_slot(slot, self)
		
		# Handle any errors
		if error == ItemInventory.InventoryError.FILTER_DENIED:
			return InstanceError.FILTER_DENIED
		if error == ItemInventory.InventoryError.DIFFERENT_TYPES:
			return InstanceError.DIFFERENT_TYPES
		if error == ItemInventory.InventoryError.NO_FIT:
			return InstanceError.NO_FIT
		# Tell us about unhandled errors
		if error != ItemInventory.InventoryError.OK:
			printerr("`put_in_inventory` encountered unknown `_put_item_in_slot` error code %s" % error)
			return InstanceError.UNKNOWN
		
		# Reparent us to the inventory to make it easier to visualize where
		# the item is, in the editor
		_remove_from_inventory()
		_remove_from_world()
		_change_parent(inventory)
		
		_space_state = SpaceState.IN_INVENTORY
		_current_parent_inventory = inventory
		_if_empty_free() # Free ourselves if we have no stack left
		return InstanceError.OK # We put correctly!

## Places this item back into a limbo state, existing mostly just in memory.
## If it was in the world, it is removed from the game world. If it was in an
## inventory, it is removed from that inventory.
func put_nowhere() -> void:
	_remove_from_world() # Make sure we're no longer in the world
	_remove_from_inventory() # Make sure we're no longer in an inventory
	
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
	if slot_index != - 1:
		_current_parent_inventory._take_item_from_slot(slot_index)
	_current_parent_inventory = null
	_space_state = SpaceState.NOWHERE
	return slot_index != - 1

## Remove this instance from the game world, if it's placed there.
## Returns:
##	`true` if it was removed from the world, and the WorldItem was free'd
##	`false` if there was no WorldItem, and we're not in the game world.
func _remove_from_world() -> bool:
	var actually_removed = false
	
	# Remove our 2D world item, if there is one.
	if _current_world_item_2d != null:
		_current_world_item_2d.queue_free()
		_current_world_item_2d = null
		actually_removed = false
	# Remove our 3D world item, if there is one.
	if _current_world_item_3d != null:
		_current_world_item_3d.queue_free()
		_current_world_item_3d = null
		actually_removed = false

	# If we didn't end up removing any world items, EXIT EARLY
	if not actually_removed: return false

	# OTHERWISE - we removed world items, so update our state properly!
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
