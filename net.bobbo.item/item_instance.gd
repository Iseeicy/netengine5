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
	
	# TODO
	return true

## Places this item instance in an inventory. If it was in the world, it is
## removed from the game world. If it was in a different inventory, it is
## removed from that inventory.
## Returns:
## - `true` if the item was place in the inventory
## - `false` if the item was rejected by the inventory
func put_in_inventory(inventory: ItemInventory) -> bool:
	# TODO
	return false
